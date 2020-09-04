using System;
using UnityEngine;
using UnityEngine.Events;
using Valve.VR;

namespace HumboldtForum.VR
{
    public class HeadsetStateChecker : MonoBehaviour
    {
        [Tooltip("This action lets you know when the player has placed the headset on their head")]
        public SteamVR_Action_Boolean headsetOnHead = SteamVR_Input.GetBooleanAction("HeadsetOnHead");
        public HeadSetChangedEvent OnHeadsetChanged;

        public bool IsHeadSetOn { get => isHeadSetOn; }

        private bool isHeadSetOn;

        void Start()
        {
            if (headsetOnHead != null)
            {
                isHeadSetOn = headsetOnHead.GetLastState(SteamVR_Input_Sources.Head);
                OnHeadsetChanged?.Invoke(isHeadSetOn);
            }
        }

        // Update is called once per frame
        void Update()
        {
            if (headsetOnHead != null)
            {
                bool onNow = isHeadSetOn;
                if (headsetOnHead.GetStateDown(SteamVR_Input_Sources.Head))
                {
                    Debug.Log($"{this} Headset placed on head", this);
                    isHeadSetOn = true;
                }
                else if (headsetOnHead.GetStateUp(SteamVR_Input_Sources.Head))
                {
                    Debug.Log($"{this} Headset removed", this);
                    isHeadSetOn = false;
                }
                if (isHeadSetOn != onNow)
                {
                    OnHeadsetChanged?.Invoke(isHeadSetOn);
                }
            }
        }
    }

    [Serializable]
    public class HeadSetChangedEvent : UnityEvent<bool> { }

}