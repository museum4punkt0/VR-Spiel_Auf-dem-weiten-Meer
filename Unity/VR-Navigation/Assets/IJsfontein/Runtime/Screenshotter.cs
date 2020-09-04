using UnityEngine;
using System.IO;

namespace IJsfontein.Dev
{
    public class Screenshotter : MonoBehaviour
    {
        public KeyCode Key = KeyCode.P;

        public bool OnlyInEditor = false;
        public bool DontDestroy = false;

        public int superSize = 1;

        void Awake()
        {
            if (!Application.isEditor && OnlyInEditor)
            {
                enabled = false;
            }
            if (this.DontDestroy)
            {
                DontDestroyOnLoad(this);
            }
        }

        // Update is called once per frame
        void Update()
        {
            if (Input.GetKeyDown(Key))
            {
                string folder = System.Environment.GetFolderPath(System.Environment.SpecialFolder.Desktop);
                string now = System.DateTime.Now.ToString("yyMMdd-HHmmss");
                string filename = Path.Combine(folder, Application.productName + " Screenshots");

                if (!Directory.Exists(filename))
                {
                    Directory.CreateDirectory(filename);
                }

                ScreenCapture.CaptureScreenshot(Path.Combine(filename, now + ".png"), superSize);
            }
        }
    }
}