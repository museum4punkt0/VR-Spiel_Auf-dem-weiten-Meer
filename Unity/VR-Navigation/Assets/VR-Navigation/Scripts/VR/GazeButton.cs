using System;
using UnityEngine;
using UnityEngine.Events;

namespace HumboldtForum.VR
{
    [RequireComponent(typeof(Collider))]
    public class GazeButton : MonoBehaviour
    {
        public GazeEnterEvent OnGazeEnter;
        public UnityEvent OnGazeExit;
        public UnityEvent OnSelected;

        internal void GazeExit()
        {
            OnGazeExit?.Invoke();
        }

        internal void GazeEnter(GazeInput gazeInput)
        {
            OnGazeEnter?.Invoke(gazeInput);
        }

         public void InvokeSelected()
         {
             OnSelected?.Invoke();
         }

         public void OnEnable()
         {
             GetComponent<Collider>().enabled = true;
         }

         public void OnDisable()
         {
             GetComponent<Collider>().enabled = false;
         }
    }

    [Serializable] public class GazeEnterEvent : UnityEvent<GazeInput> { }
}