using UnityEngine;
using IJsfontein.AppUpdater;
using UnityEngine.UI;

namespace IJsfontein.Versioning
{
    public class VersionInfo : MonoBehaviour
    {
        public Version version;

        void Start()
        {
            string info = $"version {version.versionString} - {version.branchName} build {version.buildNumber}";
            info = info.Replace("  ", " ");

            gameObject.GetComponent<Text>().text = info;
        }
    }
}