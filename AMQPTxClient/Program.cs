using System.Diagnostics;
using System.Text;
using RabbitMQ.Client;

const string hostName = "localhost";

var cts = new CancellationTokenSource();

Console.CancelKeyPress += new ConsoleCancelEventHandler(CancelHandler);

void CancelHandler(object? sender, ConsoleCancelEventArgs e)
{
    Console.WriteLine("CTRL-C pressed, exiting!");
    e.Cancel = true;
    cts.Cancel();
}

var cf = new ConnectionFactory();

const string exchangeName = "vesc-1073-fanout";
const string routingKey = "vesc-1073";

for (int i = 0; i < 3; i++)
{
    int port = 5672 + i;
    var ep = new AmqpTcpEndpoint(hostName, port);
    cf.Endpoint = ep;

    string queueName = $"vesc-1073-{i}";

    using (var conn = cf.CreateConnection())
    {
        using (var ch = conn.CreateModel())
        {
            ch.ExchangeDeclare(exchangeName, "fanout", durable: true, autoDelete: false);

            var queueArgs = new Dictionary<string, object>
            {
                { "x-queue-type", "quorum" }
            };

            QueueDeclareOk queueDeclareResult = ch.QueueDeclare(queue: queueName, exclusive: false, durable: true, autoDelete: false, arguments: queueArgs);
            Debug.Assert(String.Equals(queueName, queueDeclareResult.QueueName));

            ch.QueueBind(queue: queueName, exchange: exchangeName, routingKey: routingKey);
        }
    }
}

var tasks = new List<Task>();

for (int i = 0; i < 3; i++)
{
    int taskPort = 5672 + i;
    var publishAction = async () =>
    {
        var taskCf = new ConnectionFactory();
        var taskEp = new AmqpTcpEndpoint(hostName, taskPort);
        taskCf.Endpoint = taskEp;
        Console.WriteLine("[INFO] opening connection to {0}", taskEp.ToString());
        string queueName = $"vesc-1073-{i}";
        using (var conn = taskCf.CreateConnection())
        {
            using (var ch = conn.CreateModel())
            {
                ch.TxSelect();
                while (!cts.IsCancellationRequested)
                {
                    ch.BasicPublish(exchange: exchangeName, routingKey: routingKey, mandatory: true, body: Encoding.ASCII.GetBytes(i.ToString()));
                    ch.TxCommit();
                    await Task.Delay(TimeSpan.FromSeconds(1));
                }
            }
        }
    };

    tasks.Add(Task.Run(publishAction));
}

Console.WriteLine("[INFO] waiting for publishers to stop...");
await Task.WhenAll(tasks);
