using UnityEngine;

namespace HumboldtForum
{
    public class IslandSinker : MonoBehaviour
    {
        [SerializeField] Transform player = default;
        [SerializeField] float minDistance = default;
        [SerializeField] float maxDistance = default;
        [SerializeField] Transform targetPosition = default;
        private Vector3 originalPosition;
        private Vector3 movement;

        void Awake()
        {
            originalPosition = transform.position;
            movement = targetPosition.position - originalPosition;
        }

        void Update()
        {
            float distance = (player.transform.position - originalPosition).magnitude;
            float t = Mathf.InverseLerp(minDistance, maxDistance, distance);
            t = Mathf.Clamp01(t);
            transform.position = originalPosition + (movement * t);
        }
    }
}