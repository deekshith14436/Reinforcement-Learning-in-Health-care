classdef MultiAgentPatientHealthEnv < rl.env.MATLABEnvironment
    properties
        % Health Metrics (State Variables)
        HeartRate
        BloodPressure
        OxygenSaturation
        GlucoseLevel
        RespirationRate
        PainLevel
        MedicationAdherence
        ActivityLevel
        BodyTemperature
        MentalAlertness
        DietAdherence
        SleepQuality
        HealthCondition % Current health condition (e.g., 'Healthy', 'Chronic')

        % Environment Variables
        MaxSteps = 150;
        CurrentStep = 0;
        AgentIndex = 1; % Tracks the current agent in sequence

        % Follow-Up Log
        FollowUpLog % Cell array to store follow-up data
        LogFileName = "FollowUpLogs.xlsx"; % File to save logs
    end

    properties(Access = protected)
        % Valid Actions for Each Agent
        ValidActions

        % Define Action Spaces for Each Agent
        Agent1_ActionSpace = [1, 2, 3]; % Agent 1: Normalize metrics
        Agent2_ActionSpace = [1, 2, 3]; % Agent 2: Anomaly detection
        Agent3_ActionSpace = [1, 2, 3]; % Agent 3: Treatment
        Agent4_ActionSpace = [1, 2, 3]; % Agent 4: Follow-up monitoring
    end

    methods
        % Constructor
        function this = MultiAgentPatientHealthEnv()
            % Define Observation Space
            ObservationInfo = rlNumericSpec([1 12], ...
                'LowerLimit', [50, 80, 85, 70, 10, 0, 0, 0, 36, 0, 0, 0], ...
                'UpperLimit', [100, 180, 100, 200, 30, 10, 1, 1, 40, 10, 1, 10]);
            ObservationInfo.Name = 'Patient Metrics';

            % Define Action Space
            ActionInfo = rlFiniteSetSpec([1 2 3]);
            ActionInfo.Name = 'Actions';

            % Call Superclass Constructor
            this = this@rl.env.MATLABEnvironment(ObservationInfo, ActionInfo);

            % Initialize Valid Actions for Each Agent
            this.ValidActions{1} = this.Agent1_ActionSpace; % Agent 1: Normalize metrics
            this.ValidActions{2} = this.Agent2_ActionSpace; % Agent 2: Anomaly detection
            this.ValidActions{3} = this.Agent3_ActionSpace; % Agent 3:  
            this.ValidActions{4} = this.Agent4_ActionSpace; % Agent 4: Follow-up monitoring

            % Initialize Follow-Up Log
            this.FollowUpLog = {};

            % Reset environment
            reset(this);
        end

        % Reset Function
        function InitialObservation = reset(this)
            % Initialize Metrics
            this.HeartRate = randi([60, 100]);
            this.BloodPressure = randi([110, 140]);
            this.OxygenSaturation = randi([90, 100]);
            this.GlucoseLevel = randi([70, 150]);
            this.RespirationRate = randi([12, 20]);
            this.PainLevel = randi([0, 10]);
            this.MedicationAdherence = rand();
            this.ActivityLevel = rand();
            this.BodyTemperature = rand() * 4 + 36; % 36–40°C
            this.MentalAlertness = randi([0, 10]);
            this.DietAdherence = rand();
            this.SleepQuality = randi([0, 10]);
            this.CurrentStep = 0;
            this.AgentIndex = 1;
            this.FollowUpLog = {}; % Clear the log

            % Classify health condition
            this.HealthCondition = this.classifyHealth();

            % Initial Observation
            InitialObservation = this.getObservation();
        end

        % Step Function
        function [NextObservation, Reward, IsDone, LoggedSignals] = step(this, Action)
            % Extract action from cell array if necessary
            if iscell(Action)
                Action = Action{1};
            end

            % Default Reward
            Reward = 0;

            % Check if the action is valid for the current agent
            if ~ismember(Action, this.ValidActions{this.AgentIndex})
                Reward = -10; % Penalty for invalid action
            else
                % Perform the action based on the current agent
                switch this.AgentIndex
                    case 1 % Agent 1: Normalize Health Metrics
                        Reward = this.normalizeMetrics(Action);
                    case 2 % Agent 2: Detect Anomalies
                        Reward = this.detectAnomalies(Action);
                    case 3 % Agent 3: Recommend Treatment
                        Reward = this.recommendTreatment(Action);
                    case 4 % Agent 4: Follow-Up Monitoring
                        Reward = this.followUpMonitoring(Action);
                end
            end

            % Simulate patient state dynamics
            this.simulatePatientState();

            % Update health condition after action
            PreviousCondition = this.HealthCondition;
            this.HealthCondition = this.classifyHealth();

            % Add rewards for improving or worsening health condition
            if strcmp(PreviousCondition, 'Chronic') && strcmp(this.HealthCondition, 'Critical')
                Reward = Reward + 5; % Bonus for improvement
            elseif strcmp(this.HealthCondition, 'Healthy')
                Reward = Reward + 20; % Bonus for reaching goal
            elseif strcmp(PreviousCondition, 'Critical') && strcmp(this.HealthCondition, 'Chronic')
                Reward = Reward - 5; % Penalty for worsening condition
            end

            % Prepare the next observation
            NextObservation = this.getObservation();
            this.CurrentStep = this.CurrentStep + 1;

            % Cycle to the next agent
            this.AgentIndex = mod(this.AgentIndex, 4) + 1;

            % Check termination condition
            IsDone = strcmp(this.HealthCondition, 'Healthy');

            % Log signals
            LoggedSignals = struct('HealthCondition', this.HealthCondition);

            
        end

        % Simulate Patient State Dynamics
        function simulatePatientState(this)
            % Adjust patient health based on MedicationAdherence and other factors
            adherenceFactor = 1 - this.MedicationAdherence;
            this.HeartRate = min(100, max(60, this.HeartRate + adherenceFactor * randn() * 2));
            this.GlucoseLevel = min(200, max(70, this.GlucoseLevel + adherenceFactor * randn() * 5));
            this.RespirationRate = min(30, max(10, this.RespirationRate + adherenceFactor * randn()));
            this.PainLevel = min(10, max(0, this.PainLevel + adherenceFactor * randn() * 0.5));
            this.BodyTemperature = min(40, max(36, this.BodyTemperature + adherenceFactor * randn() * 0.1));
            this.SleepQuality = min(10, max(0, this.SleepQuality + adherenceFactor * randn() * 0.1));
        end

        % Get Current Observation
        function Observation = getObservation(this)
            Observation = [
                this.HeartRate, this.BloodPressure, this.OxygenSaturation, ...
                this.GlucoseLevel, this.RespirationRate, this.PainLevel, ...
                this.MedicationAdherence, this.ActivityLevel, this.BodyTemperature, ...
                this.MentalAlertness, this.DietAdherence, this.SleepQuality];
        end

        % Classify Health Condition
        function Condition = classifyHealth(this)
            if this.HeartRate >= 60 && this.HeartRate <= 80 && ...
               this.BloodPressure >= 110 && this.BloodPressure <= 120 && ...
               this.OxygenSaturation >= 95 && this.GlucoseLevel >= 70 && this.GlucoseLevel <= 110 && ...
               this.PainLevel <= 3
                Condition = 'Healthy';
            elseif this.PainLevel > 7 || this.GlucoseLevel > 180
                Condition = 'Chronic';
            elseif this.PainLevel > 5 || this.GlucoseLevel > 150
                Condition = 'Critical';
            elseif this.PainLevel > 4 || this.GlucoseLevel > 130
                Condition = 'Severe';
            else
                Condition = 'Moderate';
            end
        end

        % Normalize Metrics (Agent 1)
        function Reward = normalizeMetrics(this, Action)
            switch Action
                case 1 % Correct action: Administer medication
                    this.HeartRate = max(60, this.HeartRate - 5);
                    this.BloodPressure = max(110, this.BloodPressure - 5);
                    Reward = 5;
                case 2 % Wrong medication
                    this.HeartRate = min(100, this.HeartRate + 5);
                    this.BloodPressure = min(180, this.BloodPressure + 5);
                    Reward = -5;
                case 3 % No action
                    this.HeartRate = min(100, this.HeartRate + 2);
                    this.BloodPressure = min(180, this.BloodPressure + 2);
                    Reward = -2;
                otherwise
                    Reward = -10; % Invalid action
            end
        end

        % Detect Anomalies (Agent 2)
        function Reward = detectAnomalies(this, Action)
            switch Action
                case 1 % Correct detection
                    if this.HeartRate > 90 || this.OxygenSaturation < 95
                        Reward = 10;
                        % Corrective action
                        this.HeartRate = max(60, this.HeartRate - 5);
                        this.OxygenSaturation = min(100, this.OxygenSaturation + 2);
                    else
                        Reward = -5; % False positive
                    end
                case 2 % Incorrect detection
                    if this.HeartRate > 90 || this.OxygenSaturation < 95
                        Reward = -10; % Missed anomaly
                    else
                        Reward = 0;
                    end
                case 3 % No action
                    Reward = -5; % Penalty for inaction
                otherwise
                    Reward = -10; % Invalid action
            end
        end

        % Recommend Treatment (Agent 3)
        function Reward = recommendTreatment(this, Action)
            switch Action
                case 1 % Correct medication
                    this.GlucoseLevel = max(70, this.GlucoseLevel - 10);
                    Reward = 10;
                case 2 % Wrong medication
                    this.GlucoseLevel = min(200, this.GlucoseLevel + 10);
                    Reward = -10;
                case 3 % No treatment
                    this.GlucoseLevel = min(200, this.GlucoseLevel + 5);
                    Reward = -5;
                otherwise
                    Reward = -10; % Invalid action
            end
        end

        % Follow-Up Monitoring (Agent 4)
        function Reward = followUpMonitoring(this, Action)
            switch Action
                case 1 % Proper monitoring
                    this.FollowUpLog{end+1} = struct('Step', this.CurrentStep, ...
                        'HealthCondition', this.HealthCondition, ...
                        'Metrics', this.getObservation());
                    Reward = 10;
                case 2 % Inadequate monitoring
                    Reward = -5;
                case 3 % No monitoring
                    Reward = -10;
                otherwise
                    Reward = -10; % Invalid action
            end
        end
    end
end
