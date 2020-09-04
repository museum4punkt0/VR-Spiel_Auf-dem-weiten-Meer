using System.IO;
using IJsfontein;
using IJsfontein.AppUpdater;
using IJsfontein.Build;
using UnityEditor;
using UnityEngine;

namespace HumboldtForum.Build
{
    public class Windows
    {
        [MenuItem("Tools/Humboldt-Forum/Build Windows Exe and Installer %&b")]
        public static void BuildExeAndInstaller()
        {
            CommandLineArgs args = new CommandLineArgs();

            string[] scenes = new string[] {
                "Assets/VR-Navigation/Scenes/Intro.unity",
                "Assets/VR-Navigation/Scenes/Main.unity"
            };

            string branch = args.GetBinaryArgument("-branch");
            if (string.IsNullOrEmpty(branch))
            {
                branch = "dev/test";
            }

            const string targetDir = "Builds/Windows";

            string baseName = "VR-Wasawasa";

            string version = args.GetBinaryArgument("-version");
            string setupName = args.GetBinaryArgument("-setupName");
            if (string.IsNullOrEmpty(setupName))
            {
                setupName = baseName + "-setup" + "-" + branch;
            }
            setupName = setupName.Replace('/', '-');

            if (!UpdateUpdaterAsset(setupName, branch))
            {
                FailIfBatchMode(args);
            }
            else
            {

                int buildNumber = PlayerBuilder.GetBuildNumber(args);
                if (!PlayerBuilder.BuildWindows64BitsExe(targetDir, exeBaseName: baseName, scenes: scenes, branch: branch, version: version, buildNumber: buildNumber))
                {
                    FailIfBatchMode(args);
                }
                else
                {
                    string sourceDir = Application.dataPath + "/../" + targetDir;
                    Debug.LogFormat("Installer sourceDir: {0}", sourceDir);
                    if (!string.IsNullOrEmpty(branch))
                    {
                        baseName += "-" + branch.Replace("/", "-");
                    }
                    if (!BuildInstaller(args, baseName, setupName, sourceDir, version, buildNumber))
                    {
                        FailIfBatchMode(args);
                    }
                }
            }
        }

        private static bool BuildInstaller(CommandLineArgs args, string productName, string setupName, string sourceDir, string version, int buildNumber)
        {
            CreateBatchFile(productName, sourceDir);
            string installerArguments = "/dAppName=" + productName.Replace(" ", "");
            installerArguments += " " + "/dAppVersion=" + version;

            if (buildNumber > 0)
            {
                installerArguments += " " + "/dAppBuild=" + buildNumber;
            }
            else
            {
                installerArguments += " " + "/dAppBuild=0";
            }

            installerArguments += " " + "/dSetupName=" + setupName;
            installerArguments += " " + "/dSourceDir=" + sourceDir;

            string resultPath = Application.dataPath + "/../../../";
            return new InnoInstallerBuilder().Build(resultPath + "Installer", installerArguments);
        }

        /// <summary>
        /// Create batch file that will be used to start the application full screen
        /// </summary>
        private static void CreateBatchFile(string ProductName, string targetDir)
        {
            Debug.LogFormat("create batch file for product {0}", ProductName);

            StreamWriter w = new StreamWriter(targetDir + "/run.bat");
            w.WriteLine(@"pushd ""%~dp0""");
            w.WriteLine(@"cd / D ""%~dp0""");
            if (PlayerSettings.fullScreenMode == FullScreenMode.FullScreenWindow)
            {
                w.WriteLine("start " + ProductName + ".exe -screen-fullscreen 1 -popupwindow");
            }
            else
            {
                w.WriteLine("start " + ProductName + ".exe -popupwindow -screen-width " + PlayerSettings.defaultScreenWidth + " -screen-height " + PlayerSettings.defaultScreenHeight);
            }
            w.Close();
        }

        private static void FailIfBatchMode(CommandLineArgs args)
        {
            if (args.GetUnaryArgument("-batchmode"))
            {
                EditorApplication.Exit(1); // FAIL!
            }
        }

        private static bool UpdateUpdaterAsset(string setupName, string branch)
        {
            UpdaterSettings updaterSettings;
            bool foundExistingAsset = AssetDatabaseUtil.LoadAsset<UpdaterSettings>(out updaterSettings);
            if (!foundExistingAsset)
            {
                Debug.LogWarning("NO UPDATER SETTINGS ASSET FOUND");
                return false;
            }

            if (!string.IsNullOrEmpty(setupName))
            {
                updaterSettings.SetupName = setupName;
            }
            if (!string.IsNullOrEmpty(branch))
            {
                updaterSettings.ProjectName = branch;
            }

            EditorUtility.SetDirty(updaterSettings);
            AssetDatabase.SaveAssets();

            return true;
        }

    }

}
