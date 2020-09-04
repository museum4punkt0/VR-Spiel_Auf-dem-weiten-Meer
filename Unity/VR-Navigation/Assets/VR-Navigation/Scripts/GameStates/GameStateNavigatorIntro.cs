using IJsfontein.GameStates;
using UnityEngine.Playables;

namespace HumboldtForum.GameStates
{
    public class GameStateNavigatorIntro : GameState
    {
        private readonly PlayableDirector navigatorIntroTimeline;

        public GameStateNavigatorIntro(GameContext context) : base(context, Main.LayerName.NavigatorIntro)
        {
            navigatorIntroTimeline = GetComponentForLayer<PlayableDirector>("NavigatorIntroduction");
        }

        override public void Activate(AbstractGameState previousState)
        {
            base.Activate(previousState);
            navigatorIntroTimeline.stopped += Next;
        }

        override public void Deactivate(AbstractGameState nextState)
        {
            navigatorIntroTimeline.stopped -= Next;
            base.Deactivate(nextState);
        }

        private void Next(PlayableDirector timeline)
        {
            context.StateMachine.SetState(new GameStateTurtleIntro(context));
        }
    }
}