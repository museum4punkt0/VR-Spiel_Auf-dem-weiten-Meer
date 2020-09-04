using UnityEngine;

namespace HumboldtForum
{
    public class DistanceScaler : MonoBehaviour
    {
        [SerializeField] Transform player = default;
        [SerializeField] float minDistance = default;
        [SerializeField] float maxDistance = default;
        [SerializeField] float minScale = 0;
        [SerializeField] float maxScale = 1;

        void Update()
        {
            float distance = (player.transform.position - transform.position).magnitude;
            float t = Mathf.InverseLerp(minDistance, maxDistance, distance);
            float s = Mathf.Lerp(maxScale, minScale, t);
            transform.localScale = Vector3.one * s;
        }

        void OnDrawGizmosSelected()
        {
            // Display the explosion radius when selected
            Gizmos.color = new Color(1, 1, 0, 0.75F);
            Gizmos.DrawWireSphere(transform.position, minDistance);
            // Display the explosion radius when selected
            Gizmos.color = new Color(1, 0, 1, 0.75F);
            Gizmos.DrawWireSphere(transform.position, maxDistance);
        }
    }
}