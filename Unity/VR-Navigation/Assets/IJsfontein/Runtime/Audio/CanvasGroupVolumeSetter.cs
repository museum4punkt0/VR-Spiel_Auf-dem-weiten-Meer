using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IJsfontein.Audio
{
    // [RequireComponent(typeof(CanvasGroup))]
    [RequireComponent(typeof(AudioLibraryClipPlayer))]
    public class CanvasGroupVolumeSetter : MonoBehaviour
    {
        [SerializeField]
        private CanvasGroup canvasGroup;
        private AudioLibraryClipPlayer clipPlayer;

        // Use this for initialization
        void Awake()
        {
            if (canvasGroup == null)
            {
                canvasGroup = GetComponentInParent<CanvasGroup>();
            }
            if (canvasGroup != null)
            {
                Debug.LogFormat(this + ": using canvas group {0}", canvasGroup);
            }
            enabled = (canvasGroup != null);

            clipPlayer = GetComponent<AudioLibraryClipPlayer>();
        }

        // Update is called once per frame
        void Update()
        {
            clipPlayer.SetVolume(canvasGroup.alpha);
        }
    }
}