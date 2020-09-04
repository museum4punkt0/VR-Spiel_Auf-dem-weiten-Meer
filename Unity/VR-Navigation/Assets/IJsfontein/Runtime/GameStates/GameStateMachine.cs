using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine.Assertions;
using UnityEngine.Events;

namespace IJsfontein.GameStates
{
    public class GameStateMachine
    {
        protected List<AbstractGameState> states = new List<AbstractGameState>();
        public readonly UnityEvent StateChanged = new UnityEvent();

        public GameStateMachine()
        {
        }

        public AbstractGameState State => states.LastOrDefault();

        public void SetState(AbstractGameState value)
        {
            AbstractGameState current = DeactivateCurrentState(value);
            states.Clear();
            AddAndActivateState(value, current);
        }

        public void PushState(AbstractGameState value)
        {
            AbstractGameState current = DeactivateCurrentState(value);
            AddAndActivateState(value, current);
        }

        public void PopState()
        {
            AbstractGameState next = null;
            if (states.Count >= 2)
            {
                next = states.ElementAt(states.Count - 2);
            }
            AbstractGameState current = DeactivateCurrentState(next);
            states.Remove(current);
            ActivateState(next, current);
        }

        private void AddAndActivateState(AbstractGameState newState, AbstractGameState current)
        {
            states.Add(newState);
            ActivateState(newState, current);
        }

        private void ActivateState(AbstractGameState newState, AbstractGameState current)
        {
            if (newState != null)
            {
                newState.Activate(previousState: current);
            }
            StateChanged?.Invoke();
        }

        private AbstractGameState DeactivateCurrentState(AbstractGameState nextState)
        {
            AbstractGameState current = State;
            if (current != null)
            {
                current.Deactivate(nextState: nextState);
            }

            return current;
        }
    }
}