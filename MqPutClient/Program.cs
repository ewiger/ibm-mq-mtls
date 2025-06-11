using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using IBM.WMQ;

namespace MqPutClient
{
    class Program
    {
        private IDictionary<string, object> properties = null;
        private readonly string[] cmdArgs = { "-q", "-h", "-p", "-l", "-n", "-k", "-s", "-dn", "-kr", "-cr" };

        static void Main(string[] args)
        {
            Console.WriteLine("Start of MqPutClient Application\n");
            try
            {
                var mqPutClient = new Program { properties = new Dictionary<string, object>() };
                if (mqPutClient.ParseCommandline(args))
                    mqPutClient.PutMessages();
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error: {0}", ex);
            }
            Console.WriteLine("End of MqPutClient Application");
        }

        bool ParseCommandline(string[] args)
        {
            if (args.Length < 2 || args.Length % 2 == 1)
            {
                DisplayHelp();
                return false;
            }

            var cmdlineArguments = Enumerable.Range(0, args.Length / 2)
                .ToDictionary(i => args[2 * i], i => args[2 * i + 1]);

            if (!cmdlineArguments.Keys.All(x => cmdArgs.Contains(x)))
            {
                DisplayHelp();
                return false;
            }

            properties.Add(MQC.HOST_NAME_PROPERTY, cmdlineArguments.GetValueOrDefault("-h", "localhost"));
            properties.Add(MQC.PORT_PROPERTY, int.Parse(cmdlineArguments.GetValueOrDefault("-p", "1414")));
            properties.Add(MQC.CHANNEL_PROPERTY, cmdlineArguments.GetValueOrDefault("-l", "CERT.SVRCONN"));
            properties.Add(MQC.SSL_CERT_STORE_PROPERTY, cmdlineArguments.GetValueOrDefault("-k", ""));
            properties.Add(MQC.SSL_CIPHER_SPEC_PROPERTY, cmdlineArguments.GetValueOrDefault("-s", ""));
            properties.Add(MQC.SSL_PEER_NAME_PROPERTY, cmdlineArguments.GetValueOrDefault("-dn", ""));
            properties.Add(MQC.SSL_RESET_COUNT_PROPERTY, int.Parse(cmdlineArguments.GetValueOrDefault("-kr", "0")));
            properties.Add("QueueName", cmdlineArguments["-q"]);
            properties.Add("MessageCount", int.Parse(cmdlineArguments.GetValueOrDefault("-n", "1")));
            properties.Add("sslCertRevocationCheck", bool.Parse(cmdlineArguments.GetValueOrDefault("-cr", "false")));

            return true;
        }

        void DisplayHelp()
        {
            Console.WriteLine("Usage: MqPutClient -q queueName -k keyRepository -s cipherSpec [-h host -p port -l channel -n numberOfMsgs -dn sslPeerName -kr keyResetCount -cr sslCertRevocationCheck]");
        }

        void DisplayMQProperties()
        {
            Console.WriteLine("MQ Properties:");
            foreach (var kvp in properties)
                Console.WriteLine($"  {kvp.Key}: {kvp.Value}");
        }

        MQQueueManager CreateQMgrConnection()
        {
            try
            {
                var connProps = new Hashtable
                {
                    { MQC.TRANSPORT_PROPERTY, MQC.TRANSPORT_MQSERIES_MANAGED },
                    { MQC.HOST_NAME_PROPERTY, properties[MQC.HOST_NAME_PROPERTY] },
                    { MQC.PORT_PROPERTY, properties[MQC.PORT_PROPERTY] },
                    { MQC.CHANNEL_PROPERTY, properties[MQC.CHANNEL_PROPERTY] }
                };

                if (!string.IsNullOrWhiteSpace(properties[MQC.SSL_CERT_STORE_PROPERTY].ToString()))
                    connProps[MQC.SSL_CERT_STORE_PROPERTY] = properties[MQC.SSL_CERT_STORE_PROPERTY];
                if (!string.IsNullOrWhiteSpace(properties[MQC.SSL_CIPHER_SPEC_PROPERTY].ToString()))
                    connProps[MQC.SSL_CIPHER_SPEC_PROPERTY] = properties[MQC.SSL_CIPHER_SPEC_PROPERTY];
                if (!string.IsNullOrWhiteSpace(properties[MQC.SSL_PEER_NAME_PROPERTY].ToString()))
                    connProps[MQC.SSL_PEER_NAME_PROPERTY] = properties[MQC.SSL_PEER_NAME_PROPERTY];
                if ((int)properties[MQC.SSL_RESET_COUNT_PROPERTY] != 0)
                    connProps[MQC.SSL_RESET_COUNT_PROPERTY] = properties[MQC.SSL_RESET_COUNT_PROPERTY];
                if ((bool)properties["sslCertRevocationCheck"])
                    MQEnvironment.SSLCertRevocationCheck = true;

                Console.WriteLine("[DEBUG] MQ Connection Properties:");
                foreach (DictionaryEntry entry in connProps)
                {
                    Console.WriteLine($"  {entry.Key}: {entry.Value}");
                }

                return new MQQueueManager("", connProps);
            }
            catch (Exception ex)
            {
                Console.WriteLine("[ERROR] Exception in CreateQMgrConnection: {0}", ex);
                throw;
            }
        }

        void PutMessages()
        {
            var queueName = properties["QueueName"].ToString();
            var messageCount = (int)properties["MessageCount"];

            DisplayMQProperties();

            Console.Write("Connecting to queue manager... ");
            using var qmgr = CreateQMgrConnection();
            Console.WriteLine("connected.");

            Console.Write($"Accessing queue {queueName}... ");
            using var queue = qmgr.AccessQueue(queueName, MQC.MQOO_OUTPUT + MQC.MQOO_FAIL_IF_QUIESCING);
            Console.WriteLine("done.");

            var message = new MQMessage();
            message.WriteString("test message");
            var pmo = new MQPutMessageOptions();

            for (int i = 0; i < messageCount; i++)
            {
                Console.WriteLine($"Putting message {i + 1}: test message");
                queue.Put(message, pmo);
            }
        }
    }
}
