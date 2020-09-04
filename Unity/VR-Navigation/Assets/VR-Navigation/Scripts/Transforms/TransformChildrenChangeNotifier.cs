using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Events;

namespace HumboldtForum.Transforms
{
    public class TransformChildrenChangeNotifier : MonoBehaviour
    {
        List<Transform> children = new List<Transform>();

        public ChildChangedEvent OnAdded;
        public ChildChangedEvent OnDeleted;

        void OnTransformChildrenChanged()
        {
            List<Transform> currentChildren = new List<Transform>();
            for (int i = 0; i < transform.childCount; i++)
            {
                currentChildren.Add(transform.GetChild(i));
            }

            IEnumerable<Transform> deletedChildren = children.Except(currentChildren);
            IEnumerable<Transform> newChildren = currentChildren.Except(children);

            foreach (Transform t in deletedChildren)
            {
                OnDeleted?.Invoke(t);
            }
            foreach (Transform t in newChildren)
            {
                OnAdded?.Invoke(t);
            }
            children = currentChildren;
        }

        [Serializable]
        public class ChildChangedEvent : UnityEvent<Transform> { }
    }
}