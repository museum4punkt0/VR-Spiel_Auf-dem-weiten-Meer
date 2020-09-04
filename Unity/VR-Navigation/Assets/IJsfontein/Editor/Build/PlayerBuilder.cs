using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;
using Version = IJsfontein.AppUpdater.Version;

namespace IJsfontein.Build
{
    public sealed class PlayerBuilder
    {
        const string PRODUCTION_BUILD = "PRODUCTION_BUILD";
        public static bool BuildAndroid(string targetDir, string apkBaseName, string[] scenes, string appID, string branch, string version, int buildNumber)
        {
            Debug.LogFormat("Building branch {0}", branch);

            string packageName = FileNameWithBranch(apkBaseName, branch) + ".apk";

            SetAndroidAppId(appID, branch);
            return Build(BuildTarget.Android, targetDir, packageName, scenes, branch, version, buildNumber);
        }

        public static bool BuildWindows64BitsExe(string targetDir, string exeBaseName, string[] scenes, string branch, string version, int buildNumber)
        {
            Debug.LogFormat("Building branch {0}", branch);

            string packageName = FileNameWithBranch(exeBaseName, branch) + ".exe";
            return Build(BuildTarget.StandaloneWindows64, targetDir, packageName, scenes, branch, version, buildNumber);
        }

        private static bool Build(BuildTarget buildTarget, string targetDir, string fileName, string[] scenes, string branch, string version, int buildNumber)
        {
            CheckScenes(scenes);

            CleanTargetDir(targetDir);

            Debug.LogFormat("Starting build pipeline: target dir {0}, filename {1}", targetDir, fileName);

            bool isProduction = IsProductionBranch(branch);
            SetProductionBuildDefine(isProduction, BuildPipeline.GetBuildTargetGroup(buildTarget));

            Version versionInfo = UpdateVersionAsset(buildNumber, version, branch);

            SetVersionInPlayerSettings(versionInfo);

            // makes the internal name of the resulting executable reflect the product name specified
            string currentPlayerName = PlayerSettings.productName;


            PlayerSettings.productName = ProductNameWithBranch(isProduction ? "" : branch);

            BuildReport result = BuildPipeline.BuildPlayer(scenes, Path.GetFullPath(Path.Combine(targetDir, fileName)),
                buildTarget, BuildOptions.None);
            Debug.LogFormat("Build pipeline finished");

            // reset player settings
            PlayerSettings.productName = currentPlayerName;

            if (result.summary.result != BuildResult.Succeeded)
            {
                Debug.LogErrorFormat("ERROR: Build Failed: {0}", result);
                return false;
            }

            return true;
        }

        public static int GetBuildNumber(CommandLineArgs args)
        {
            int buildNumber = -1;
            int.TryParse(args.GetBinaryArgument("-build"), out buildNumber);
            return buildNumber;
        }

        private static void CleanTargetDir(string targetDir)
        {

            // Clean contents of target dir
            if (Directory.Exists(targetDir))
            {
                DirectoryInfo di = new DirectoryInfo(targetDir);

                foreach (FileInfo file in di.GetFiles())
                {
                    try
                    {
                        file.Delete();
                    }
                    catch (IOException)
                    {
                        // File is currently locked
                    }
                    catch (UnauthorizedAccessException)
                    {
                        // whatever
                    }
                }
                foreach (DirectoryInfo dir in di.GetDirectories())
                {
                    try
                    {
                        dir.Delete(true);
                    }
                    catch (IOException)
                    {
                        // dir is currently locked
                    }
                    catch (UnauthorizedAccessException)
                    {
                        // whatever
                    }
                }
            }
        }

        private static void CheckScenes(string[] scenes)
        {
            if (scenes.Length < 1)
            {
                throw new ArgumentException("Number of scenes must be greater than zero.");
            }
        }

        private static void SetVersionInPlayerSettings(Version versionInfo)
        {
            PlayerSettings.bundleVersion = versionInfo.versionString;
            PlayerSettings.Android.bundleVersionCode = versionInfo.buildNumber;
        }

        private static void SetAndroidAppId(string identifier, string branch)
        {
            if (!string.IsNullOrEmpty(branch))
            {
                branch = branch
                    .Replace("/", "")
                    .Replace(".", "")
                    .Replace("-", "");
            }

            if (!string.IsNullOrEmpty(branch))
            {
                identifier += "." + branch;
            }

            Debug.LogFormat("Setting app ID: {0}", identifier);
            PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.Android, identifier);
        }

        private static string FileNameWithBranch(string basename, string branch)
        {
            string name = basename;
            if (!string.IsNullOrEmpty(branch))
            {
                name += "-" + branch.Replace('/', '-');
            }

            return name;
        }

        private static string ProductNameWithBranch(string branchName)
        {
            string productName = Application.productName;
            if (!string.IsNullOrEmpty(branchName))
            {
                productName += "-" + branchName.Replace('/', '-');
            }
            return productName;
        }

        /// <summary>
        /// Sets the PRODUCTION_BUILD define, or removes it.
        /// </summary>
        /// <param name="branch"></param>
        /// <returns></returns>
        private static void SetProductionBuildDefine(bool isProduction, BuildTargetGroup forBuildTarget)
        {
            if (isProduction)
            {
                AddScriptingDefineSymbolForGroup(forBuildTarget, PRODUCTION_BUILD);
            }
            else
            {
                RemoveScriptingDefineSymbolForGroup(forBuildTarget, PRODUCTION_BUILD);
            }
        }

        private static bool IsProductionBranch(string branch)
        {
            return !string.IsNullOrEmpty(branch) && branch.Equals("production");
        }

        private static void AddScriptingDefineSymbolForGroup(BuildTargetGroup targetGroup, string symbol)
        {
            string existingDefines = PlayerSettings.GetScriptingDefineSymbolsForGroup(targetGroup);
            Debug.LogFormat("defines: {0}", existingDefines);
            List<string> defines = existingDefines.Split(';').ToList();

            if (!defines.Contains(symbol))
            {
                defines.Add(symbol);
                PlayerSettings.SetScriptingDefineSymbolsForGroup(targetGroup, string.Join(";", defines.ToArray()));
            }
        }

        private static void RemoveScriptingDefineSymbolForGroup(BuildTargetGroup targetGroup, string symbol)
        {
            string existingDefines = PlayerSettings.GetScriptingDefineSymbolsForGroup(targetGroup);
            Debug.LogFormat("defines: {0}", existingDefines);
            List<string> defines = existingDefines.Split(';').ToList();

            if (defines.Remove(symbol))
            {
                defines.Add(symbol);
                PlayerSettings.SetScriptingDefineSymbolsForGroup(targetGroup, string.Join(";", defines.ToArray()));
            }
        }

        private static Version UpdateVersionAsset(int buildNumber, string version, string branch)
        {
            Version versionInfo;
            bool foundExistingAsset = AssetDatabaseUtil.LoadAsset<Version>(out versionInfo);
            if (!foundExistingAsset)
            {
                Debug.LogWarning("NO VERSION ASSET FOUND");
                versionInfo = ScriptableObject.CreateInstance<Version>();
            }
            versionInfo.buildNumber = buildNumber;
            if (!string.IsNullOrEmpty(version)) // only override existing value when passed
            {
                versionInfo.versionString = version;
            }

            if (!string.IsNullOrEmpty(branch))
            {
                versionInfo.branchName = branch;
            }

            EditorUtility.SetDirty(versionInfo);
            AssetDatabase.SaveAssets();

            return versionInfo;
        }
    }
}
