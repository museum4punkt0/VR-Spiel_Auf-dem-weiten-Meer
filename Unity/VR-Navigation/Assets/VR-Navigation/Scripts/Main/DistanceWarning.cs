using System;
using UnityEngine;
using UnityEngine.Events;

namespace HumboldtForum
{
    public class DistanceWarning : MonoBehaviour
    {
        [SerializeField] Transform player = default;
        [SerializeField] float tolerance = 5;
        [Tooltip("Will only warn when distance is greater than this number")]
        [SerializeField] float minDistance = 200;

        public UnityEvent Warn;
        public UnityEvent ClearWarning;

        private float lastDistance;
        private bool isWarning;

        void Awake()
        {
            if (!player)
            {
                Debug.LogWarning($"{this}: player not set");
                enabled = false;
            }
        }

        void OnEnable()
        {
            lastDistance = GetDistance();
        }

        void Update()
        {
            float distance = GetDistance();
            if (distance > minDistance)
            {
                if (distance > lastDistance + tolerance) // sailed further than allowed
                {
                    Debug.Log($"{this}: warning: going the wrong way: {distance}", this);
                    lastDistance = distance;
                    SetWarningState(true);
                }
            }
            if (distance < lastDistance && isWarning)
            {
                Debug.Log($"{this}: getting closer again {distance}", this);
                SetWarningState(false);
            }
            lastDistance = Mathf.Min(distance, lastDistance);
        }

        private void SetWarningState(bool goingWrong)
        {
            if (goingWrong && !isWarning)
            {
                Warn?.Invoke();
                isWarning = true;
            }
            else if (!goingWrong && isWarning)
            {
                ClearWarning?.Invoke();
                isWarning = false;
            }
        }

        private float GetDistance()
        {
            return (player.transform.position - transform.position).magnitude;
        }
    }
}