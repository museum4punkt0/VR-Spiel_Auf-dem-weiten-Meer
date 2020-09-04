using System;
using IJsfontein.GameStates;

namespace HumboldtForum.GameStates
{
    internal class GameStateSailToAssignment : GameState
    {
        private readonly NavLocationTrigger targetLocation;
        private readonly DistanceWarning distanceWarning;

        public GameStateSailToAssignment(GameContext context, Main.LayerName layer) : base(context, layer)
        {
            targetLocation = GetComponentForLayer<NavLocationTrigger>();
            distanceWarning = GetComponentForLayer<DistanceWarning>();
            context.Boat.NoGoWarning.Reference = distanceWarning.transform; // make it turn into the direction we need to sail
        }

        override public void Activate(AbstractGameState previousState)
        {
            base.Activate(previousState);

            context.Boat.StartSteering.AddListener(context.Boat.StartSailing);
            context.Boat.StopSteering.AddListener(context.Boat.StopSailing);

            targetLocation.Hit.AddListener(OnTargetHit);

            distanceWarning.Warn.AddListener(OnDistanceWarning);
            distanceWarning.ClearWarning.AddListener(OnClearWarning);

            context.Boat.StartSailingWhenPaddleEnabled();
        }

        private void OnClearWarning()
        {
            context.Boat.NoGoWarning.gameObject.SetActive(false);
        }

        private void OnDistanceWarning()
        {
            context.Boat.NoGoWarning.gameObject.SetActive(true);
        }

        private void OnTargetHit()
        {
            context.SetAssignmentState();
        }

        override public void Deactivate(AbstractGameState nextState)
        {
            context.Boat.StartSteering.RemoveListener(context.Boat.StartSailing);
            context.Boat.StopSteering.RemoveListener(context.Boat.StopSailing);

            distanceWarning.Warn.RemoveListener(OnDistanceWarning);
            distanceWarning.ClearWarning.RemoveListener(OnClearWarning);

            targetLocation.Hit.RemoveListener(OnTargetHit);

            base.Deactivate(nextState);
        }
    }
}