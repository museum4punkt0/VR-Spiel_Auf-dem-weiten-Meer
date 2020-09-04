using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using IJsfontein.Audio;
using UnityEngine;
using UnityEngine.Playables;
using HumboldtForum.Timeline;
using UnityEngine.Assertions;

namespace HumboldtForum.Controls
{
    [RequireComponent(typeof(Collider))]
    public class CollisionHelp : MonoBehaviour
    {
        [SerializeField] PlayableDirector timeline = default;
        [SerializeField] float buttonActivateDuration = 20;

        int activeCollisions = 0;

        void Awake()
        {
            timeline.stopped += OnTimelineStopped;
            timeline.played += OnTimelinePlayed;
            timeline.paused += OnTimelinePaused;
        }

        private void OnTimelinePaused(PlayableDirector obj)
        {
            Debug.Log($"{this} timeline paused at {obj.time}", this);
        }

        private void OnTimelinePlayed(PlayableDirector obj)
        {
            Debug.Log($"{this} timeline played at {obj.time}", this);
            CancelButtonDisableTimeout();
        }

        private void OnTimelineStopped(PlayableDirector obj)
        {
            Debug.Log($"{this} timeline stopped at {obj.time}", this);
            // CancelButtonDisableTimeout();
            if (obj.time == 0) //wrapped around!
            {
                Debug.Log($"{this}: end of help, {activeCollisions} collisions now");
                // stopped at end: are we still colliding?
                bool stillstuck = ActivateButtonIfStillColliding();
                if(!stillstuck)
                {
                    obj.Seek(0);
                }
            }
        }

        private bool ActivateButtonIfStillColliding()
        {
            bool stillStuck = activeCollisions > 0;
            if (stillStuck)
            {
                LabelMarker m = timeline.LabelMarkerTimes()["HelpAvailable"];
                timeline.Seek(m);
                Debug.Log($"{this}: reactivating button");
                ActivateButtonTimeout();
            }
            return stillStuck;
        }

        void OnTriggerEnter(Collider other)
        {
            if (!other.isTrigger)
            {
                activeCollisions++;
                Debug.Log($"{this} collided {other.gameObject}/{other.isTrigger}: {activeCollisions} collisions now", this);
                if (timeline.time == 0)
                {
                    timeline.Play();
                }
                ActivateButtonTimeout();
            }
        }

        private void ActivateButtonTimeout()
        {
            CancelButtonDisableTimeout();
            Debug.Log($"{this}: will start delay to switch button off in {buttonActivateDuration}", this);
            DOVirtual.DelayedCall(buttonActivateDuration, () =>
            {
                Debug.Log($"{this}: timeout triggered", this);
                if (!ActivateButtonIfStillColliding())
                {
                    Debug.Log($"{this}: resetting timeline", this);
                    timeline.Seek(0);
                    timeline.Stop();
                }
            }).SetId(this);
        }

        void OnTriggerExit(Collider other)
        {
            if (!other.isTrigger)
            {
                activeCollisions--;
                Debug.Log($"{this} escaped {other.gameObject}: {activeCollisions} collisions now", this);
            }
            Assert.IsTrue(activeCollisions >= 0, "Active collisions should never go below 0?!");
        }

        void OnDisable()
        {
            Debug.Log($"{this} Disabled", this);
            CancelButtonDisableTimeout();
        }

        private void CancelButtonDisableTimeout()
        {
            Debug.Log($"{this}: cancel button timeout", this);
            DOTween.Kill(this);
        }

        void OnEnable()
        {
            Debug.Log($"{this} Enabled", this);
            timeline.Seek(0);
        }
    }
}