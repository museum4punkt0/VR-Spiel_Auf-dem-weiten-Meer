using UnityEngine;

namespace IJsfontein.AppUpdater
{
    [CreateAssetMenu(fileName = "UpdaterSettings", menuName = "App Updater/Settings")]
    public class UpdaterSettings : ScriptableObject
    {
        public StartupBehaviour StartUp = StartupBehaviour.DontCheck;
        [Header("Server")]
        public string UpdateURL = "https://updates.ijsfontein.nl";

        [Header("Subfolder(s) on server")]
        public string ProjectName = "";

        [Header("Installer name (without extension!)")]
        public string SetupName = "Setup";

        [Header("Installer command line parameters")]
        public string SetupParameters = "/SP- /SILENT /NORESTART /TASKS=\"desktopicon,launch\" /CLOSEAPPLICATIONS /LOG ";

        public bool useBasicAuthentication;
        [HideInInspector]
        public string username;
        [HideInInspector]
        public string password;

        public enum StartupBehaviour
        {
            DontCheck = 0,
            Check = 1,
            DownloadAndInstall = 2
        }
    }

}