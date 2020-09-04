using System.IO;
using UnityEngine;

namespace IJsfontein
{
    public static class LogHandler
    {
        private static StreamWriter streamWriter = default;
        private static bool useTimestamp = true;
        const int NUM_DAYS_TO_KEEP = 30;

#if AUTO_LOG_SETUP
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSplashScreen)]
        public static void Setup()
        {
            Setup(true);
            Debug.Log($"LogHandler: Automatic logging initialized");
        }
#endif

        public static void Setup(bool useTimestamp = true)
        {

            if (streamWriter != null) // don't reinitialize everything if setup already happened
            {
                return;
            }

            // Setup log file
            LogHandler.useTimestamp = useTimestamp;

            // Create logs directory
            // On Windows: C:\Users\<username>\<appname>
            // On Mac: /Users/<username>/<appname>
            string applicationUserDirectory = MyDocumentsPath.AppFolder;
            if (!Directory.Exists(applicationUserDirectory))
            {
                try
                {
                    Directory.CreateDirectory(applicationUserDirectory);
                }
                catch (System.Exception)
                {
                    applicationUserDirectory = Application.dataPath;
                }
            }

            // Check if there are any .log files older than <N> days, and remove them
            System.DateTime now = System.DateTime.Now;
            System.DateTime minimumData = now.AddDays(-NUM_DAYS_TO_KEEP);
            string[] files = Directory.GetFiles(applicationUserDirectory, "*.log");
            for (int i = 0; i < files.Length; i++)
            {
                System.DateTime creationTime = File.GetCreationTime(files[i]);
                if (creationTime < minimumData)
                {
                    File.Delete(files[i]);
                }
            }

            // Do nothing in editor
#if !UNITY_EDITOR
            // Create streamwriter
            streamWriter = new StreamWriter(applicationUserDirectory + Path.DirectorySeparatorChar + now.ToString("yyyy-MM-dd") + ".log", true);
            // Log writing is done to a different thread
            Application.logMessageReceivedThreaded += OnLogHandler;

            System.AppDomain.CurrentDomain.UnhandledException += HandleUnhandledException;
#endif
        }

        public static void Teardown()
        {
#if !UNITY_EDITOR
            System.AppDomain.CurrentDomain.UnhandledException -= HandleUnhandledException;
            Application.logMessageReceivedThreaded -= OnLogHandler;

            if (streamWriter != null)
            {
                streamWriter.Close();
            }
#endif
        }

        private static void OnLogHandler(string message, string stackTrace, LogType type)
        {
            if (useTimestamp)
            {
                streamWriter.Write(string.Format("{0:yyyy/MM/dd HH:mm:ss} - ", System.DateTime.Now));
            }

            streamWriter.WriteLine(type.ToString("F").PadRight(9) + ": " + message);
            if (type == LogType.Error || type == LogType.Exception || type == LogType.Assert)
            {
                streamWriter.Write(stackTrace);
                streamWriter.WriteLine("");
            }
            streamWriter.Flush();
        }

        private static void HandleUnhandledException(object sender, System.UnhandledExceptionEventArgs args)
        {
            if (args == null || args.ExceptionObject == null)
            {
                return;
            }

            if (args.ExceptionObject.GetType() == typeof(System.Exception))
            {
                System.Exception e = (System.Exception)args.ExceptionObject;
                OnLogHandler(string.Format("Unhandled Exception at {0}", e.Source), e.StackTrace, LogType.Exception);
            }
        }
    }
}