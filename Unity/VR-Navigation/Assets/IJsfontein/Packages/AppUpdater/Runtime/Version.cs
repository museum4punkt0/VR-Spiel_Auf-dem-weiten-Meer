using System;
using UnityEngine;
namespace IJsfontein.AppUpdater
{
    [CreateAssetMenu(fileName = "Version.asset", menuName = "App Updater/Version Info")]
    [Serializable]
    public class Version : ScriptableObject
    {
        public int buildNumber = -1;
        public string versionString = "0.0";
        public string branchName;
        // public int svnRevision = -1;
        // public string gitCommit ="undefined";
        // public string gitBranch = "undefined"; } }
    }
}