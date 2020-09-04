using System;
using UnityEngine;
using UnityEngine.Events;
using Valve.VR.InteractionSystem;

namespace HumboldtForum.VR
{
    [RequireComponent(typeof(Interactable))]
    public class HandAttacher : MonoBehaviour
    {
        public UnityEvent OnGrab;
        public UnityEvent OnRelease;
        public UnityEvent OnHandEnter;
        public UnityEvent OnHandLeave;

        private Interactable interactable;

        void Awake()
        {
            interactable = GetComponent<Interactable>();
        }

        /// this magic method is called by hand while hovering
        protected virtual void HandHoverUpdate(Hand hand)
        {
            GrabTypes startingGrabType = hand.GetGrabStarting();

            if (interactable.attachedToHand == null && startingGrabType != GrabTypes.None)
            {
                hand.AttachObject(gameObject, startingGrabType, Hand.AttachmentFlags.DetachFromOtherHand | Hand.AttachmentFlags.ParentToHand);
                OnGrab?.Invoke();
            }
        }

        protected virtual void OnHandHoverBegin(Hand hand)
        {
            OnHandEnter?.Invoke();
        }

        protected virtual void OnHandHoverEnd(Hand hand)
        {
            OnHandLeave?.Invoke();
        }

        protected virtual void HandAttachedUpdate(Hand hand)
        {
            if (hand.IsGrabEnding(gameObject))
            {
                hand.DetachObject(gameObject);
                OnRelease?.Invoke();
            }
        }
    }
}