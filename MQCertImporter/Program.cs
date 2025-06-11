using System.Security.Cryptography.X509Certificates;

namespace MQCertImporter
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 2)
            {
                Console.WriteLine("Usage: MQCertImporter <p12Path> <p12Password>");
                return;
            }

            string p12Path = args[0];
            string p12Password = args[1];

            try
            {
                using (X509Store store = new X509Store(StoreName.My, StoreLocation.CurrentUser))
                {
                    store.Open(OpenFlags.ReadWrite);

                    // Import all certificates from the PKCS#12 (.p12) file
                    X509Certificate2Collection collection = new X509Certificate2Collection();
                    collection.Import(p12Path, p12Password, X509KeyStorageFlags.PersistKeySet | X509KeyStorageFlags.Exportable);

                    foreach (X509Certificate2 cert in collection)
                    {
                        store.Add(cert);
                        Console.WriteLine($"Certificate '{cert.Subject}' installed successfully");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                Environment.Exit(1);
            }
        }
    }
}
