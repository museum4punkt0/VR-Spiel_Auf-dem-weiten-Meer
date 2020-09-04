using UnityEngine;
using UnityEngine.Events;

namespace HumboldtForum
{
    public class ColliderTrigger : MonoBehaviour
    {
        [SerializeField] protected string hitTag = "Player";
        [SerializeField] bool EnableTriggers = true;
        [SerializeField] bool EnableCollisions = true;
        public UnityEvent Hit;
        public UnityEvent Exit;


        void OnTriggerEnter(Collider other)
        {
            if (EnableTriggers)
            {
                InvokeHit(other);
            }
        }

        private void InvokeHit(Collider other)
        {
            if (other.gameObject.CompareTag(hitTag))
            {
                // Debug.Log($"{this} hit {hitTag}! ({other})", this);
                Hit?.Invoke();
            }
        }

        void OnTriggerExit(Collider other)
        {
            if (EnableTriggers)
            {
                InvokeExit(other);
            }
        }

        private void InvokeExit(Collider other)
        {
            if (other.gameObject.CompareTag(hitTag))
            {
                // Debug.Log($"{this} exit {hitTag}! ({other})", this);
                Exit?.Invoke();
            }
        }

        void OnCollisionEnter(Collision hit)
        {
            if (EnableCollisions)
            {
                InvokeHit(hit.collider);
            }
        }

        void OnCollisionExit(Collision hit)
        {
            if (EnableCollisions)
            {
                InvokeExit(hit.collider);
            }
        }
    }
}