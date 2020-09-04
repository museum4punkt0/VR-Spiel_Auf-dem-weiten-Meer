using IJsfontein.LayerElements;
using UnityEngine;

namespace IJsfontein.GameStates
{
    public abstract class AbstractGameState
    {
        protected IGameContext context;
        protected int uiLayer;

        protected bool isActive { get; private set; }
        protected ElementsLayer Layer { get { return GetLayer(uiLayer); } }

        protected AbstractGameState(IGameContext context, int uiLayer)
        {
            this.uiLayer = uiLayer;
            this.context = context;
            Debug.Log($"<b>{this.GetType().Name}</b> Initialized");
        }

        virtual public void Activate(AbstractGameState previousState)
        {
            if (context.LayerSwitcher != null)
            {
                if (previousState != null)
                {
                    int other = previousState.uiLayer;
                    GameObject[] transitionIn = context.LayerSwitcher.GameObjectsOnlyIn(context.LayerSwitcher.GetLayer(uiLayer), notIn: context.LayerSwitcher.GetLayer(other));
                    HandleTransitionIn(transitionIn);
                }
                else
                {
                    context.LayerSwitcher.ActivateLayer(uiLayer);
                }
            }
            isActive = true;
        }

        virtual public void Deactivate(AbstractGameState nextState)
        {
            if (context.LayerSwitcher != null)
            {
                GameObject[] transitionOut = default;
                if (nextState != null)
                {
                    int other = nextState.uiLayer;
                    transitionOut = context.LayerSwitcher.GameObjectsOnlyIn(context.LayerSwitcher.GetLayer(uiLayer), notIn: context.LayerSwitcher.GetLayer(other));
                }
                else
                {
                    transitionOut = context.LayerSwitcher.GameObjectsForLayer(context.LayerSwitcher.GetLayer(uiLayer));
                }
                HandleTransitionOut(transitionOut);
            }
            isActive = false;
        }

        virtual public void HandleTransitionIn(GameObject[] elements)
        {
            //  activate elements!
            foreach (GameObject g in elements)
            {
                g.SetActive(true);
            }
        }

        virtual public void HandleTransitionOut(GameObject[] elements)
        {
            foreach (GameObject g in elements)
            {
                g.SetActive(false);
            }
        }

        public T GetComponentForLayer<T>() where T : Component
        {
            return context.LayerSwitcher.GetComponentForLayer<T>(GetLayer(uiLayer));
        }

        public T GetComponentForLayer<T>(string withGameObjectName) where T : Component
        {
            return context.LayerSwitcher.GetComponentForLayer<T>(GetLayer(uiLayer), withGameObjectName);
        }

        public T[] GetComponentsForLayer<T>() where T : Component
        {
            return context.LayerSwitcher.GetComponentsForLayer<T>(GetLayer(uiLayer));
        }

        public T[] GetComponentsForLayer<T>(string withGameObjectName) where T : Component
        {
            return context.LayerSwitcher.GetComponentsForLayer<T>(GetLayer(uiLayer), withGameObjectName);
        }

        private ElementsLayer GetLayer(int uiLayer)
        {
            return context.LayerSwitcher.GetLayer(uiLayer);
        }
    }
}
