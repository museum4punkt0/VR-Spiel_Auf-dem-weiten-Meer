using System.Text;
using UnityEditor;
using UnityEngine;
using System.IO;

namespace IJsfontein.Build
{
    /// <summary>
    /// 
    /// </summary>
    public sealed class InnoInstallerBuilder
    {
        // Do not change. This is the default install directory on 64-bit Windows.
        public const string InnoSetupApplicationPath = @"""C:\Program Files (x86)\Inno Setup 5\ISCC.exe""";

        // Used for storing output data in order to keep the log files readable
        private StringBuilder outputDataCollector;

        private bool successful = true;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="workingDirectory"></param>
        /// <param name="arguments"></param>
        public bool Build(string workingDirectory, string arguments)
        {
            outputDataCollector = new StringBuilder();

            // #if UNITY_EDITOR_WIN||true
            if (Application.platform == RuntimePlatform.WindowsEditor)
            {
                CLIRunner cliRunner = new CLIRunner();
                cliRunner.OutputDataReceived += HandleOutputDataReceived;
                cliRunner.ErrorDataReceived += HandleErrorDataReceived;

                string innoSetupCommand = InnoSetupApplicationPath + " " + arguments + " Setup.iss";

                Debug.LogFormat("Inno Setup: {0} in {1}", innoSetupCommand, workingDirectory);

                // Run with working directory the installer directory
                cliRunner.BeginCommand(innoSetupCommand, workingDirectory);

                int exitCode = cliRunner.EndCommand();

                cliRunner.OutputDataReceived -= HandleOutputDataReceived;
                cliRunner.ErrorDataReceived -= HandleErrorDataReceived;

                LogOutputData();

                Debug.Log("Done");

                if (exitCode != 0)
                {
                    Debug.LogErrorFormat("Running Inno Setup failed with exit code {0}", exitCode);
                    return false;
                }
                else
                {
                    return successful; // may have been set to false in HandleErrorDataReceived
                }
            }
            else
            {
                Debug.LogError("Unsupported Platform");
                return false;
            }
        }

        private void LogOutputData()
        {
            if (outputDataCollector.Length > 0)
            {
                Debug.Log(outputDataCollector.ToString());
                outputDataCollector.Length = 0;
            }
        }

        private void HandleOutputDataReceived(string message)
        {
            outputDataCollector.AppendLine(message);
        }

        private void HandleErrorDataReceived(string message)
        {
            LogOutputData();
            Debug.LogError(message);
            successful = false;
        }
    }
}
