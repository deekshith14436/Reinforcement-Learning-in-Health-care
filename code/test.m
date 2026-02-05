% patient_health_simulation_with_agents_complete.m

% Clear the workspace and command window
clear;
clc;

% Load trained agents
% Replace 'agent1_Trained.mat', etc., with the actual filenames of your saved agents
load('agent1_Trained.mat', 'agent1_Trained');
load('agent2_Trained.mat', 'agent2_Trained');
load('agent3_Trained.mat', 'agent3_Trained');
load('agent4_Trained.mat', 'agent4_Trained');

% Initialize Patient's State
patient = struct();
patient.HeartRate = input('Enter patient''s heart rate (60-100): ');
patient.BloodPressure = input('Enter patient''s blood pressure (80-180): ');
patient.OxygenSaturation = input('Enter patient''s oxygen saturation (85-100): ');
patient.GlucoseLevel = input('Enter patient''s glucose level (70-200): ');
patient.PainLevel = input('Enter patient''s pain level (0-10): ');

% Initialize additional health metrics with default values
patient.RespirationRate = 16; % Average value
patient.MedicationAdherence = 1; % Assume full adherence initially
patient.ActivityLevel = 0.5; % Default activity level
patient.BodyTemperature = 37; % Normal body temperature
patient.MentalAlertness = 5; % Average mental alertness
patient.DietAdherence = 1; % Full diet adherence
patient.SleepQuality = 5; % Average sleep quality

patient.HealthCondition = classifyHealth(patient);
patient.IsDischarged = false;

% Initialize Log Data
logData = [];
stepNumber = 0;

fprintf('\nInitial Health Condition: %s\n', patient.HealthCondition);

% Simulation Loop
while ~patient.IsDischarged
    stepNumber = stepNumber + 1;
    fprintf('\nStep %d\n', stepNumber);
    
    % Display current health metrics
    fprintf('Current Health Metrics:\n');
    fprintf('Heart Rate: %.2f\n', patient.HeartRate);
    fprintf('Blood Pressure: %.2f\n', patient.BloodPressure);
    fprintf('Oxygen Saturation: %.2f\n', patient.OxygenSaturation);
    fprintf('Glucose Level: %.2f\n', patient.GlucoseLevel);
    fprintf('Pain Level: %.2f\n', patient.PainLevel);
    
    % Prepare observation vector with all 12 elements
    observation = [patient.HeartRate, patient.BloodPressure, patient.OxygenSaturation, ...
                   patient.GlucoseLevel, patient.RespirationRate, patient.PainLevel, ...
                   patient.MedicationAdherence, patient.ActivityLevel, patient.BodyTemperature, ...
                   patient.MentalAlertness, patient.DietAdherence, patient.SleepQuality];
    
    % Reshape observation to match expected input shape [1 12]
    observation = reshape(observation, [1, numel(observation)]);
    
    % Agent 1: Normalize Metrics
    fprintf('\nAgent 1 Suggestion:\n');
    % Get action from Agent 1
    action1 = getAction(agent1_Trained, observation);
    action1 = action1{1};
    % Display action suggestion
    action1Text = getAgent1ActionText(action1);
    fprintf('Agent 1 suggests: %s\n', action1Text);
    
    % Agent 2: Detect Anomalies
    fprintf('\nAgent 2 Suggestion:\n');
    action2 = getAction(agent2_Trained, observation);
    action2 = action2{1};
    action2Text = getAgent2ActionText(action2);
    fprintf('Agent 2 suggests: %s\n', action2Text);
    
    % Agent 3: Recommend Treatment
    fprintf('\nAgent 3 Suggestion:\n');
    action3 = getAction(agent3_Trained, observation);
    action3 = action3{1};
    action3Text = getAgent3ActionText(action3);
    fprintf('Agent 3 suggests: %s\n', action3Text);
    
    % Agent 4: Follow-Up Monitoring
    fprintf('\nAgent 4 Suggestion:\n');
    action4 = getAction(agent4_Trained, observation);
    action4 = action4{1};
    action4Text = getAgent4ActionText(action4);
    fprintf('Agent 4 suggests: %s\n', action4Text);
    
    % Ask user to input actions (override or accept agent suggestions)
    fprintf('\nPlease enter your actions (you can accept agent suggestions or choose your own):\n');
    
    % Option to terminate simulation
    terminateSimulation = input('Enter ''q'' to quit or press Enter to continue: ', 's');
    if strcmpi(terminateSimulation, 'q')
        fprintf('\nSimulation terminated by user.\n');
        break; % Exit the simulation loop
    end
    
    % Action: Rest
    restAction = '';
    while ~ismember(restAction, {'1', '2'})
        restAction = input('1. Rest\n2. No Rest\nEnter choice (1 or 2): ', 's');
    end
    restAction = str2double(restAction);
    
    % Action: Medication
    medicationAction = '';
    while ~ismember(medicationAction, {'1', '2', '3'})
        medicationAction = input('1. Correct Medication\n2. Wrong Medication\n3. No Medication\nEnter choice (1, 2, or 3): ', 's');
    end
    medicationAction = str2double(medicationAction);
    
    % Update patient state based on actions
    % Effects of Rest Action (Increased impact)
    if restAction == 1 % Rest
        patient.HeartRate = max(60, patient.HeartRate - 7); % Increased improvement
        patient.PainLevel = max(0, patient.PainLevel - 2); % Increased improvement
        fprintf('\nPatient is resting. Heart rate and pain level improved significantly.\n');
    else % No Rest
        patient.HeartRate = min(100, patient.HeartRate + 1); % Reduced worsening
        patient.PainLevel = min(10, patient.PainLevel + 0.5); % Reduced worsening
        fprintf('\nPatient is not resting. Heart rate and pain level may worsen slightly.\n');
    end
    
    % Effects of Medication Action (Increased impact)
    if medicationAction == 1 % Correct Medication
        patient.GlucoseLevel = max(70, patient.GlucoseLevel - 15); % Increased improvement
        patient.PainLevel = max(0, patient.PainLevel - 3); % Increased improvement
        fprintf('Correct medication administered. Glucose level and pain level improved significantly.\n');
    elseif medicationAction == 2 % Wrong Medication
        patient.GlucoseLevel = min(200, patient.GlucoseLevel + 5); % Reduced negative impact
        patient.PainLevel = min(10, patient.PainLevel + 1); % Reduced negative impact
        fprintf('Wrong medication administered. Glucose level and pain level worsened slightly.\n');
    else % No Medication
        patient.GlucoseLevel = min(200, patient.GlucoseLevel + 2); % Reduced worsening
        fprintf('No medication administered. Glucose level may worsen slightly.\n');
    end
    
    % Simulate patient state dynamics (reduced random fluctuations)
    patient = simulatePatientState(patient);
    
    % Classify health condition
    previousCondition = patient.HealthCondition;
    patient.HealthCondition = classifyHealth(patient);
    
    % Calculate Rewards based on actions (similar to environment code)
    % Agent 1 Reward (Normalize Metrics)
    reward1 = calculateAgent1Reward(action1, restAction);
    % Agent 2 Reward (Detect Anomalies)
    reward2 = calculateAgent2Reward(action2, patient);
    % Agent 3 Reward (Recommend Treatment)
    reward3 = calculateAgent3Reward(action3, medicationAction);
    % Agent 4 Reward (Follow-Up Monitoring)
    reward4 = calculateAgent4Reward(action4, patient);
    
    % Log Data
    logEntry = struct();
    logEntry.Step = stepNumber;
    logEntry.HeartRate = patient.HeartRate;
    logEntry.BloodPressure = patient.BloodPressure;
    logEntry.OxygenSaturation = patient.OxygenSaturation;
    logEntry.GlucoseLevel = patient.GlucoseLevel;
    logEntry.PainLevel = patient.PainLevel;
    logEntry.HealthCondition = patient.HealthCondition;
    logEntry.RestAction = restAction;
    logEntry.MedicationAction = medicationAction;
    logEntry.Reward1 = reward1;
    logEntry.Reward2 = reward2;
    logEntry.Reward3 = reward3;
    logEntry.Reward4 = reward4;
    
    logData = [logData; logEntry];
    
    % Provide feedback and suggestions
    fprintf('\nUpdated Health Condition: %s\n', patient.HealthCondition);
    provideSuggestions(patient.HealthCondition);
    
    % Check if patient can be discharged
    if strcmp(patient.HealthCondition, 'Healthy')
        patient.IsDischarged = true;
        fprintf('\nCongratulations! The patient is healthy and can be discharged.\n');
        break; % Exit the simulation loop
    elseif ~strcmp(previousCondition, patient.HealthCondition)
        fprintf('Note: The patient''s health condition has changed from %s to %s.\n', previousCondition, patient.HealthCondition);
    end
end

% Save logs to Excel file
if ~isempty(logData)
    logTable = struct2table(logData);
    writetable(logTable, 'patient_health_log.xlsx');
    fprintf('\nSimulation log saved to patient_health_log.xlsx\n');
else
    fprintf('\nNo data to save.\n');
end

%% Helper Functions

% Function to classify health condition
function condition = classifyHealth(patient)
    if patient.HeartRate >= 60 && patient.HeartRate <= 80 && ...
       patient.BloodPressure >= 110 && patient.BloodPressure <= 120 && ...
       patient.OxygenSaturation >= 95 && patient.GlucoseLevel >= 70 && patient.GlucoseLevel <= 110 && ...
       patient.PainLevel <= 3
        condition = 'Healthy';
    elseif patient.PainLevel > 7 || patient.GlucoseLevel > 180
        condition = 'Chronic';
    elseif patient.PainLevel > 5 || patient.GlucoseLevel > 150
        condition = 'Critical';
    elseif patient.PainLevel > 4 || patient.GlucoseLevel > 130
        condition = 'Severe';
    else
        condition = 'Moderate';
    end
end

% Function to simulate patient state dynamics (reduced fluctuations)
function patient = simulatePatientState(patient)
    % Reduced random fluctuations in health metrics
    patient.HeartRate = min(100, max(60, patient.HeartRate + randn() * 0.5));
    patient.BloodPressure = min(180, max(80, patient.BloodPressure + randn() * 0.5));
    patient.OxygenSaturation = min(100, max(85, patient.OxygenSaturation + randn() * 0.2));
    patient.GlucoseLevel = min(200, max(70, patient.GlucoseLevel + randn() * 1));
    patient.PainLevel = min(10, max(0, patient.PainLevel + randn() * 0.1));
end

% Function to provide suggestions based on health condition
function provideSuggestions(condition)
    switch condition
        case 'Healthy'
            fprintf('Keep up the good work! Maintain a healthy lifestyle.\n');
        case 'Moderate'
            fprintf('Consider resting and following your medication plan. Monitor your health metrics regularly.\n');
        case 'Severe'
            fprintf('Your condition is severe. It is advised to consult a healthcare professional immediately.\n');
        case 'Critical'
            fprintf('Your condition is critical! Seek emergency medical attention now!\n');
        case 'Chronic'
            fprintf('You have a chronic condition. Long-term treatment and lifestyle changes are necessary.\n');
        otherwise
            fprintf('Health condition unknown. Please provide valid inputs.\n');
    end
end

% Function to get Agent 1 action text
function actionText = getAgent1ActionText(action)
    switch action
        case 1
            actionText = 'Administer correct medication';
        case 2
            actionText = 'Administer wrong medication';
        case 3
            actionText = 'No action';
        otherwise
            actionText = 'Unknown action';
    end
end

% Function to get Agent 2 action text
function actionText = getAgent2ActionText(action)
    switch action
        case 1
            actionText = 'Detect anomalies';
        case 2
            actionText = 'Incorrect detection';
        case 3
            actionText = 'No action';
        otherwise
            actionText = 'Unknown action';
    end
end

% Function to get Agent 3 action text
function actionText = getAgent3ActionText(action)
    switch action
        case 1
            actionText = 'Recommend correct treatment';
        case 2
            actionText = 'Recommend wrong treatment';
        case 3
            actionText = 'No treatment';
        otherwise
            actionText = 'Unknown action';
    end
end

% Function to get Agent 4 action text
function actionText = getAgent4ActionText(action)
    switch action
        case 1
            actionText = 'Proper monitoring';
        case 2
            actionText = 'Inadequate monitoring';
        case 3
            actionText = 'No monitoring';
        otherwise
            actionText = 'Unknown action';
    end
end

% Function to calculate Agent 1 reward
function reward = calculateAgent1Reward(agentAction, userAction)
    % Map restAction to Agent 1 action
    % restAction: 1 (Rest), 2 (No Rest)
    % Agent 1 actions: 1 (Administer correct medication), 2 (Administer wrong medication), 3 (No action)
    % For simplicity, we'll consider:
    % If user chose Rest (1) and agent suggested 'Administer correct medication' (1), reward is positive
    if agentAction == 1 && userAction == 1
        reward = 5;
    elseif agentAction == 2 && userAction == 2
        reward = -5;
    else
        reward = -2;
    end
end

% Function to calculate Agent 2 reward
function reward = calculateAgent2Reward(agentAction, patient)
    % Determine if there is an anomaly
    anomalies = detectAnomalies(patient);
    hasAnomalies = any(anomalies);
    
    % Agent 2 actions: 1 (Detect anomalies), 2 (Incorrect detection), 3 (No action)
    if agentAction == 1 % Detect anomalies
        if hasAnomalies
            reward = 5; % Correctly detected anomalies
        else
            reward = -3; % False positive
        end
    elseif agentAction == 2 % Incorrect detection
        reward = -5; % Incorrect detection
    elseif agentAction == 3 % No action
        if hasAnomalies
            reward = -5; % Missed anomalies
        else
            reward = 2; % Correctly did nothing
        end
    else
        reward = 0; % Unknown action
    end
end

% Function to detect anomalies in patient's metrics
function anomalies = detectAnomalies(patient)
    anomalies = [
        patient.HeartRate < 60 || patient.HeartRate > 100, ...
        patient.BloodPressure < 80 || patient.BloodPressure > 180, ...
        patient.OxygenSaturation < 95, ...
        patient.GlucoseLevel < 70 || patient.GlucoseLevel > 140, ...
        patient.PainLevel > 5
    ];
end

% Function to calculate Agent 3 reward
function reward = calculateAgent3Reward(agentAction, userAction)
    % Map medicationAction to Agent 3 action
    % medicationAction: 1 (Correct Medication), 2 (Wrong Medication), 3 (No Medication)
    % Agent 3 actions: 1 (Recommend correct treatment), 2 (Recommend wrong treatment), 3 (No treatment)
    if agentAction == userAction
        if agentAction == 1
            reward = 10;
        elseif agentAction == 2
            reward = -10;
        else
            reward = -5;
        end
    else
        reward = -5; % Penalty for not following agent's recommendation
    end
end

% Function to calculate Agent 4 reward
function reward = calculateAgent4Reward(agentAction, patient)
    % Agent 4 actions: 1 (Proper monitoring), 2 (Inadequate monitoring), 3 (No monitoring)
    % For simplicity, we'll base the reward on whether the patient's health is improving
    if agentAction == 1 % Proper monitoring
        if isImproving(patient)
            reward = 5; % Monitoring contributing to improvement
        else
            reward = 2; % Monitoring but no improvement
        end
    elseif agentAction == 2 % Inadequate monitoring
        reward = -3; % Insufficient monitoring
    elseif agentAction == 3 % No monitoring
        reward = -5; % No monitoring when needed
    else
        reward = 0; % Unknown action
    end
end

% Function to check if patient's health is improving
function improving = isImproving(patient)
    % For simplicity, assume health is improving if pain level or glucose level decreased
    % In actual implementation, compare with previous metrics
    % Here, we can't compare with previous metrics, so we'll assume improvement if in 'Moderate' or better condition
    improving = strcmp(patient.HealthCondition, 'Moderate') || strcmp(patient.HealthCondition, 'Healthy');
end
