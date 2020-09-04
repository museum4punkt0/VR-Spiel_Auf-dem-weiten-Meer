// #define DEBUGGING
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;
using UnityEngine.Assertions;

namespace IJsfontein.LayerElements
{
    [ExecuteInEditMode]
    public class ElementsLayerSwitcher : MonoBehaviour
    {
        [SerializeField] [HideInInspector] private int selectedLayer;
        public int SelectedLayer { get => selectedLayer; }

        [SerializeField] private ElementsLayer[] layers = new ElementsLayer[] { };
        public ElementsLayer[] Layers { get => layers; }

        public ElementsLayer CurrentLayer { get => layers.ElementAtOrDefault(selectedLayer); }

        private List<GameObject> allManagedGameObjects;

#if UNITY_EDITOR
        public bool showEnumSection;
        public UnityEditor.MonoScript enumFile;
        public string enumNamespaceOverride;
#endif

        void Awake()
        {
            UpdateManagedObjectsList();
        }

        private void UpdateManagedObjectsList()
        {
            allManagedGameObjects = layers.SelectMany(l => l.Elements).Where(g => g != null).Distinct().ToList();
        }

        public ElementsLayer GetLayer(int index)
        {
            return layers[index];
        }

        public ElementsLayer GetLayer(string name)
        {
            return layers.Where(l => l.Name == name).FirstOrDefault();
        }

        public T[] GetComponentsForLayer<T>(ElementsLayer uiLayer, string withGameObjectName) where T : Component
        {
            return ComponentsForLayer<T>(uiLayer, withGameObjectName).ToArray();
        }

        public T[] GetComponentsForLayer<T>(ElementsLayer uiLayer) where T : Component
        {
            return ComponentsForLayer<T>(uiLayer).ToArray();
        }

        public T GetComponentForLayer<T>(ElementsLayer uiLayer) where T : Component
        {
            try
            {
                return ComponentsForLayer<T>(uiLayer).First();
            }
            catch (Exception)
            {
                throw new ArgumentException(string.Format("No Components of type {0} found in Layer {1}", typeof(T), uiLayer.Name));
            }
        }

        public T GetComponentForLayer<T>(ElementsLayer uiLayer, string inGameObjectNamed) where T : Component
        {
            try
            {
                return ComponentsForLayer<T>(uiLayer, inGameObjectNamed).First();
            }
            catch (Exception)
            {
                throw new ArgumentException(string.Format("Game Object named {0} not found or has no Components of type {1}", inGameObjectNamed, typeof(T)));
            }
        }

        private IEnumerable<T> ComponentsForLayer<T>(ElementsLayer uiLayer) where T : Component
        {
            return GameObjectsForLayer(uiLayer).SelectMany((g) => g.GetComponentsInChildren<T>(includeInactive: true));
        }

        private IEnumerable<T> ComponentsForLayer<T>(ElementsLayer uiLayer, string withGameObjectName) where T : Component
        {
            return ComponentsForLayer<T>(uiLayer).Where(c => c.gameObject.name == withGameObjectName);
        }

#if UNITY_EDITOR
        public void Refresh()
        {
            if (!Application.isPlaying)
            {
                UpdateManagedObjectsList();
                ActivateLayer(selectedLayer);
            }
        }
#endif

        private void ActivateOnlyElements(GameObject[] gameObjects)
        {
            if (allManagedGameObjects == null)
            {
                UpdateManagedObjectsList();
            }
            foreach (GameObject g in allManagedGameObjects)
            {
                bool shouldBeActive = gameObjects != null && gameObjects.Contains(g);
                if (Application.isPlaying) // only call these methods when playing otherwise it may screw up the scene we're editing
                {
                    ILayerTransitionHandler[] transitionHandlers = g.GetComponentsInChildren<ILayerTransitionHandler>();
                    bool componentWillHandleActivationChange = false;
                    foreach (ILayerTransitionHandler handler in transitionHandlers)
                    {
                        if (shouldBeActive && !g.activeSelf)
                        {
                            componentWillHandleActivationChange |= handler.OnLayerElementWillBeActivated(g);
                        }
                        else if (g.activeSelf)
                        {
                            componentWillHandleActivationChange |= handler.OnLayerElementWillBeDeactivated(g);
                        }
                    }
                    if (!componentWillHandleActivationChange)
                    {
                        g.SetActive(shouldBeActive);
                    }
                    // else we will have to trust the Component(s) to activate the GameObject as they promised
                }
                else
                {
                    g?.SetActive(shouldBeActive);
                }
            }
        }

        public void ActivateLayer(int layerIndex)
        {
            ElementsLayer layer = null;
            if (layerIndex >= 0 && layerIndex < layers.Length)
            {
                layer = layers[layerIndex];
            }
#if DEBUGGING
            if (layer != null)
            {
                Debug.LogFormat(this + ":Activating UI Elements for layer {0}", layer.Name);
            }
            else
            {
                Debug.LogFormat(this + ":Deactivating all layers");
            }
#endif
            GameObject[] elements = null;
            if (layer != null)
            {
                elements = GameObjectsForLayer(layer);
            }
            ActivateOnlyElements(elements);
            selectedLayer = layerIndex;
        }

        public GameObject[] CommonGameObjects(ElementsLayer one, ElementsLayer other)
        {
            GameObject[] first = one.Elements;
            GameObject[] second = other.Elements;
            return first.Intersect(second).ToArray();
        }

        public GameObject[] GameObjectsOnlyIn(ElementsLayer layer, ElementsLayer notIn)
        {
            GameObject[] layerElements = layer.Elements;
            GameObject[] otherElements = notIn.Elements;
            return layerElements.Except(otherElements).ToArray();
        }

        public GameObject[] GameObjectsForLayer(ElementsLayer layer)
        {
            if (layer == null)
            {
                throw new ArgumentException("Layer cannot be null");
            }

            return layer.Elements;
        }
    }

    [Serializable]
    public class ElementsLayer
    {
        [SerializeField] private string name = null;
        [SerializeField] private GameObject[] elements = null;
        public GameObject[] Elements { get => elements; }
        public string Name { get => name; }
    }

    public interface ILayerTransitionHandler
    {
        bool OnLayerElementWillBeActivated(GameObject g);
        bool OnLayerElementWillBeDeactivated(GameObject g);
    }
}