using UnityEngine;
using System;
using System.Collections.Generic;

namespace IJsfontein
{
    public class CommandLineArgs
    {
        private Dictionary<string, bool> unaryArguments;
        private Dictionary<string, string> binaryArguments;

        /// <summary>
        ///
        /// </summary>
        public CommandLineArgs()
            : this(new Dictionary<string, bool>(), new Dictionary<string, string>())
        {

        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="unaryArguments"></param>
        /// <param name="binaryArguments"></param>
        public CommandLineArgs(Dictionary<string, bool> unaryArguments, Dictionary<string, string> binaryArguments)
        {
            this.unaryArguments = unaryArguments;
            this.binaryArguments = binaryArguments;

            // Parse command line options
#if !NETFX_CORE
            string[] commandLineArgs = Environment.GetCommandLineArgs();
#else
            string[] commandLineArgs = new string[] {};
#endif
            // The first argument is the application name called, which is Unity in our case
            for (int i = 1; i < commandLineArgs.Length; i++)
            {
                // Options are either unary or binary, depending wether the argument key, starting with '-'
                // is followed by one without
                string key = commandLineArgs[i];
                string value = null;
                if (i < (commandLineArgs.Length - 1) && (!commandLineArgs[i + 1].StartsWith("-")))
                {
                    value = commandLineArgs[i + 1];
                    i++;
                }

                if (string.IsNullOrEmpty(value))
                {
                    // Unary option
                    if (unaryArguments.ContainsKey(key))
                    {
                        this.unaryArguments[key] = true;
                    }
                    else
                    {
                        this.unaryArguments.Add(key, true);
                    }
                }
                else
                {
                    // Binary option
                    if (binaryArguments.ContainsKey(key))
                    {
                        this.binaryArguments[key] = value;
                    }
                    else
                    {
                        this.binaryArguments.Add(key, value);
                    }
                }
            }

            // Log arguments
            string message = "Command line args: " + string.Join(" ", commandLineArgs) + Environment.NewLine;

            message += "Unary arguments:" + Environment.NewLine;
            foreach (KeyValuePair<string, bool> entry in this.unaryArguments)
            {
                message += "  " + entry.Key + ": " + entry.Value.ToString() + Environment.NewLine;
            }

            message += "Binary arguments:" + Environment.NewLine;
            foreach (KeyValuePair<string, string> entry in this.binaryArguments)
            {
                message += "  " + entry.Key + ": " + entry.Value.ToString() + Environment.NewLine;
            }

            Debug.Log(message);
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        public bool GetUnaryArgument(string name)
        {
            if (unaryArguments.ContainsKey(name))
            {
                return unaryArguments[name];
            }

            return false;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        public string GetBinaryArgument(string name)
        {
            if (binaryArguments.ContainsKey(name))
            {
                return binaryArguments[name];
            }

            return null;
        }
    }
}
