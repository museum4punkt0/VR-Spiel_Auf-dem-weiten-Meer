#if !NETFX_CORE

using System;
using System.Diagnostics;
using System.IO;
using System.Threading;
using UnityEngine;
using UnityEngine.Events;

namespace IJsfontein.Build
{
    public class CLIRunner
    {
        #region Public Fields & Properties

        /// <summary>
        /// Note this is not called from the main thread!
        /// </summary>
        public event UnityAction<string> OutputDataReceived;

        /// <summary>
        /// Note this is not called from the main thread!
        /// </summary>
        public event UnityAction<string> ErrorDataReceived;

        #endregion

        #region Private Fields

        private Process process;
        private Thread standardOutputThread;
        private Thread standardErrorThread;

        #endregion

        /// <summary>
        /// 
        /// </summary>
        /// <param name="command"></param>
        public void BeginCommand(string command)
        {
            BeginCommand(command, false, false, null);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="command"></param>
        /// <param name="showWindow"></param>
        public void BeginCommand(string command, bool showWindow)
        {
            BeginCommand(command, showWindow, false, null);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="command"></param>
        /// <param name="showWindow"></param>
        /// <param name="requiresInput"></param>
        public void BeginCommand(string command, bool showWindow, bool requiresInput)
        {
            BeginCommand(command, showWindow, requiresInput, null);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="command"></param>
        /// <param name="workingDirectory"></param>
        public void BeginCommand(string command, string workingDirectory)
        {
            BeginCommand(command, false, false, workingDirectory);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="command"></param>
        /// <param name="showWindow"></param>
        /// <param name="workingDirectory"></param>
        public void BeginCommand(string command, bool showWindow, string workingDirectory)
        {
            BeginCommand(command, showWindow, false, workingDirectory);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="command"></param>
        /// <param name="showWindow"></param>
        /// <param name="requiresInput"></param>
        /// <param name="workingDirectory"></param>
        public void BeginCommand(string command, bool showWindow,
            bool requiresInput, string workingDirectory)
        {
            // Check if platform is supported
            if (Application.platform != RuntimePlatform.OSXEditor &&
                Application.platform != RuntimePlatform.OSXPlayer &&
                Application.platform != RuntimePlatform.WindowsEditor &&
                Application.platform != RuntimePlatform.WindowsPlayer)
            {
                throw new NotImplementedException("Unsupported platform");
            }

            if (process != null)
            {
                throw new InvalidOperationException("A call to BeginCommand has already been done. " +
                    "Call EndCommand before starting a new one.");
            }

            // Setup process start info
            ProcessStartInfo startInfo;
            switch (Application.platform)
            {
                case RuntimePlatform.OSXEditor:
                case RuntimePlatform.OSXPlayer:
                    startInfo = new ProcessStartInfo("/bin/bash");
                    if (!string.IsNullOrEmpty(command))
                    {
                        startInfo.Arguments = "-c " + command;
                    }
                    break;
                case RuntimePlatform.WindowsEditor:
                case RuntimePlatform.WindowsPlayer:
                    startInfo = new ProcessStartInfo("cmd.exe");
                    if (!string.IsNullOrEmpty(command))
                    {
                        startInfo.Arguments = "/c " + command;
                    }
                    break;
                default:
                    throw new Exception("Should not happpen!");
            }

            if (!string.IsNullOrEmpty(workingDirectory))
            {
                startInfo.WorkingDirectory = workingDirectory;
            }

            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = !showWindow;
            startInfo.RedirectStandardOutput = true;
            startInfo.RedirectStandardError = true;
            if (requiresInput)
            {
                startInfo.RedirectStandardInput = true;
            }

            // Execute process
            process = new Process();
            process.StartInfo = startInfo;

            //process.OutputDataReceived += HandleOutputDataReceived;
            //process.ErrorDataReceived += HandleErrorDataReceived;
            process.Start();

            // See http://alabaxblog.info/2013/06/redirectstandardoutput-beginoutputreadline-pattern-broken/
            // for why the async output is not working as expected
            //process.BeginOutputReadLine();
            //process.BeginErrorReadLine();

            standardOutputThread = new Thread(() => {
                while (true)
                {
                    string data = process.StandardOutput.ReadLine();
                    if (data == null)
                    {
                        break;
                    }
                    OnOutputDataReceived(data);
                }
            });
            standardOutputThread.Start();

            standardErrorThread = new Thread(() => {
                while (true)
                {
                    string data = process.StandardError.ReadLine();
                    if (data == null)
                    {
                        break;
                    }
                    OnErrorDataReceived(data);
                }
            });
            standardErrorThread.Start();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public int EndCommand()
        {
            return EndCommand(true, 0);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="waitForExit"></param>
        /// <returns></returns>
        public int EndCommand(bool waitForExit)
        {
            return EndCommand(waitForExit, 0);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="waitForExit"></param>
        /// <param name="maxWaitForExitDuration"></param>
        public int EndCommand(bool waitForExit, int maxWaitForExitDuration = 0)
        {
            if (process == null)
            {
                throw new InvalidOperationException("A call to BeginCommand has not been done. " +
                    "Call BeginCommand before ending a one.");
            }

            if (waitForExit)
            {
                if (maxWaitForExitDuration > 0)
                {
                    process.WaitForExit(maxWaitForExitDuration);
                }
                else
                {
                    process.WaitForExit();
                }
            }

            standardOutputThread.Join();
            standardErrorThread.Join();

            //process.OutputDataReceived -= HandleOutputDataReceived;
            //process.ErrorDataReceived -= HandleErrorDataReceived;
            process.Close();

            int exitCode = 0;
            try
            {
                exitCode = process.ExitCode;
            }
            catch (Exception /*e*/) { }

            process = null;

            return exitCode;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <remarks>
        /// This has only affect if <see cref="BeginCommand(string, bool, bool)"/>
        /// is called with <code>requiresInput</code> set to <code>true</code>.
        /// </remarks>
        /// <param name="input"></param>
        public void WriteLine(string input)
        {
            if (process != null && process.StartInfo.RedirectStandardInput)
            {
                process.StandardInput.WriteLine(input);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="path"></param>
        /// <param name="showWindow"></param>
        /// <param name="requiresInput"></param>
        /// <param name="waitForExit"></param>
        /// <param name="maxWaitForExitDuration"></param>
        public int ExecuteScript(string path, bool showWindow, bool requiresInput, bool waitForExit, int maxWaitForExitDuration)
        {
            // Normalize script path
            string scriptPath = Path.GetFullPath(new Uri(path).LocalPath).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);

            if (!File.Exists(scriptPath))
            {
                throw new FileNotFoundException(string.Format("Script at {0} could not be found", path), scriptPath);
            }

            string command = "\"" + Path.GetFileName(scriptPath) + "\"";
            string workingDirectory = Path.GetDirectoryName(scriptPath);

            BeginCommand(command, showWindow, requiresInput, workingDirectory);
            return EndCommand(waitForExit, maxWaitForExitDuration);
        }

        #region Event Handlers

        private void OnOutputDataReceived(string data)
        {
            if (data != null && OutputDataReceived != null)
            {
                OutputDataReceived(data);
            }
        }

        private void OnErrorDataReceived(string data)
        {
            if (data != null && ErrorDataReceived != null)
            {
                ErrorDataReceived(data);
            }
        }

        //private void HandleOutputDataReceived(object sender, DataReceivedEventArgs e)
        //{
        //    if (e.Data != null && OutputDataReceived != null)
        //    {
        //        OutputDataReceived.Invoke(e.Data);
        //    }
        //}

        //private void HandleErrorDataReceived(object sender, DataReceivedEventArgs e)
        //{
        //    if (e.Data != null && ErrorDataReceived != null)
        //    {
        //        ErrorDataReceived.Invoke(e.Data);
        //    }
        //}

        #endregion
    }
}

#endif
