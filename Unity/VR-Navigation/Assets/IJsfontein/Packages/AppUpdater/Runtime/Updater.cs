using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using UnityEngine;
using UnityEngine.Assertions;
using UnityEngine.Networking;

using Debug = UnityEngine.Debug;

namespace IJsfontein.AppUpdater
{
    public class Updater : MonoBehaviour
    {
        [Header("UI Settings")]
        public KeyCode KeyboardShortcut = KeyCode.U;
        public UpdaterSettings settings;
        public GUIStyle messageStyle;
        public Version currentVersion;

        private string statusMessage = null;
        private UnityWebRequest installerRequest;

#if UNITY_2017_1_OR_NEWER
        void Start()
        {
            if (settings.StartUp != UpdaterSettings.StartupBehaviour.DontCheck)
            {
                bool install = settings.StartUp == UpdaterSettings.StartupBehaviour.DownloadAndInstall;
                StartCoroutine(CheckUpdate(install));
            }
        }

        void Update()
        {
            if (Input.GetKeyUp(KeyboardShortcut))
            {
                if (currentVersion != null)
                {
                    bool install = Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift);
                    StartCoroutine(CheckUpdate(install));
                }
                else
                {
                    ShowFinalMessage("Current version is unknown, won't check for update", 2);
                }
            }
            if (installerRequest != null)
            {
                float p = Mathf.Round(installerRequest.downloadProgress * 100);
                statusMessage = string.Format("Downloading update: {0}%", p);
            }
        }

        void OnGUI()
        {
            if (statusMessage != null)
            {
                GUI.Box(new Rect(0, 0, 200, 50), statusMessage, messageStyle);
            }
        }

        private static string AuthenticateBasic(string username, string password)
        {
            string auth = username + ":" + password;
            auth = System.Convert.ToBase64String(System.Text.Encoding.GetEncoding("ISO-8859-1").GetBytes(auth));
            auth = "Basic " + auth;
            return auth;
        }

        private IEnumerator CheckUpdate(bool downloadAndInstallWhenAvailable)
        {
            string baseURL = settings.UpdateURL + "/" + settings.ProjectName + "/" + settings.SetupName;
            string jsonURL = baseURL + ".info";

            statusMessage = "Checking for update";

            UnityWebRequest request = UnityWebRequest.Get(jsonURL);
            if (settings.useBasicAuthentication)
            {
                string auth = AuthenticateBasic(settings.username, settings.password);
                request.SetRequestHeader("AUTHORIZATION", auth);
            }
#if UNITY_2017_2_OR_NEWER
            yield return request.SendWebRequest();
#else
            yield return request.Send();
#endif

            if (request.isNetworkError)
            {
                Debug.LogFormat(this + ": network error: {0}", request.error);
                ShowFinalMessage(string.Format("network error: {0}", request.error), 2);
            }
            else
            {
                if (request.responseCode == 200) // success
                {
                    string text = request.downloadHandler.text;
                    Debug.LogFormat(this + "received text:{0}", text);

                    BuildInfo info = JsonUtility.FromJson<BuildInfo>(text);
                    request.downloadHandler.Dispose();

                    if (IsDifferentVersion(info, currentVersion))
                    {
                        string message = string.Format("Update available: version {0}, build {1}", info.Version, info.BuildNumber);
                        Debug.LogFormat(this + ": {0}", message);

                        if (downloadAndInstallWhenAvailable)
                        {
                            string installerURL = baseURL + ".exe";
                            string tempFolder = Application.temporaryCachePath;
                            string destinationFile = Path.Combine(tempFolder, settings.SetupName + ".exe");
                            yield return StartCoroutine(DownloadFile(installerURL, destinationFile));
                        }
                        else
                        {
                            ShowFinalMessage(message, 2);
                        }
                    }
                    else
                    {
                        ShowFinalMessage("Up to date", 2);
                    }
                }
                else
                {
                    string message = string.Format("http error: {0}", request.responseCode);
                    if (request.responseCode == 404) // not found
                    {
                        message = string.Format("Update info file not found: {0}", jsonURL);
                    }
                    Debug.LogWarning(this + ":" + message);
                    ShowFinalMessage(message, 2);
                }
            }
        }

        public static bool IsDifferentVersion(BuildInfo info, Version currentVersion)
        {
            return info.BuildNumber != currentVersion.buildNumber || currentVersion.versionString != info.Version; // Allows downgrading
        }

        private void ShowFinalMessage(string message, float timeout)
        {
            CancelInvoke("ClearMessage");
            statusMessage = message;
            Invoke("ClearMessage", timeout);
        }

        private void ClearMessage()
        {
            statusMessage = null;
        }

        private IEnumerator DownloadFile(string fileURL, string destinationFile)
        {
            installerRequest = UnityWebRequest.Get(fileURL);

            if (settings.useBasicAuthentication)
            {
                string auth = AuthenticateBasic(settings.username, settings.password);
                installerRequest.SetRequestHeader("AUTHORIZATION", auth);
            }
#if UNITY_2017_2_OR_NEWER
            yield return installerRequest.SendWebRequest();
#else
            yield return installerRequest.Send();
#endif

            statusMessage = "Downloading update";

            if (installerRequest.isNetworkError)
            {
                Debug.LogFormat(this + ": network error: {0}", installerRequest.error);
                ShowFinalMessage(string.Format("network error: {0}", installerRequest.error), 2);
            }
            else
            {
                if (installerRequest.responseCode == 200) // success
                {
                    DownloadHandler d = installerRequest.downloadHandler;
                    byte[] data = d.data;
                    installerRequest = null;

                    Debug.LogFormat(this + ": downloaded file {0}", destinationFile);

                    ShowFinalMessage("Writing file", 2);

                    File.WriteAllBytes(destinationFile, data);
                    d.Dispose();

                    RunInstaller(destinationFile);
                }
                else
                {
                    Debug.LogFormat(this + ": http error: {0}", installerRequest.responseCode);
                    ShowFinalMessage(string.Format("http error: {0}: {1}", installerRequest.responseCode, fileURL), 2);
                    installerRequest = null;
                }
            }
        }

        private void RunInstaller(string exePath)
        {
            if (Application.platform == RuntimePlatform.WindowsPlayer)
            {
                ProcessStartInfo processStartInfo = new ProcessStartInfo("cmd.exe");
                processStartInfo.WindowStyle = ProcessWindowStyle.Normal;
                processStartInfo.UseShellExecute = false;
                processStartInfo.RedirectStandardInput = true;
                processStartInfo.RedirectStandardOutput = false;
                processStartInfo.CreateNoWindow = false;

                //
                Process process = Process.Start(processStartInfo);
                if (process != null)
                {
                    //
                    process.StandardInput.WriteLine("");

                    process.StandardInput.WriteLine("\""+exePath + "\" " + settings.SetupParameters);
                    process.StandardInput.WriteLine("del \"" + exePath+"\"");

                    process.StandardInput.WriteLine("Exit");

                    Application.Quit();
                }
            }
            else
            {
                Debug.LogFormat("{0}: running installer only supported on Windows Player (you're running {1})", this, Application.platform);
                File.Delete(exePath);
            }
        }

#else
        [Obsolete("Updater only supports Unity 2017.1 and higher")]
        public static bool IsDifferentVersion(BuildInfo info, Version currentVersion)
        {
            throw new NotImplementedException();
        }

#endif

        public static void WriteInfoFile(BuildInfo info, string path)
        {
            Assert.AreNotEqual(Path.GetExtension(path), "exe", "Path should not have .exe extension");
            string json = JsonUtility.ToJson(info, prettyPrint: true);
            File.WriteAllText(path + ".info", json);
        }
    }

    /// <summary>
    /// Describes the build. Useful for checking if an update is available
    /// </summary>
    [System.Serializable]
    public class BuildInfo
    {
        public string Version;
        public string Status;
        /// <summary>
        /// This field is used to check for updates
        /// </summary>
        public int BuildNumber;
        public string Revision;
        public string UnityVersion;
        public string ReleaseNotes;
        public string Commit;
        public string Branch;
    }
}