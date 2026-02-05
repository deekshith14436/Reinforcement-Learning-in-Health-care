% List of trained agent models for DQN and PPO
dqn_agent_files = {
    'agent1_Trained.mat', 'agent2_Trained.mat', 'agent3_Trained.mat', 'agent4_Trained.mat', ...
    'agent1_Trained_1.mat', 'agent2_Trained_1.mat', 'agent3_Trained_1.mat', 'agent4_Trained_1.mat', ...
    'agent1_Trained_2.mat', 'agent2_Trained_2.mat', 'agent3_Trained_2.mat', 'agent4_Trained_2.mat'
};

ppo_agent_files = {
    'agent1_ppo_Trained.mat', 'agent2_ppo_Trained.mat', 'agent3_ppo_Trained.mat', 'agent4_ppo_Trained.mat', ...
    'agent1_ppo_Trained_1.mat', 'agent2_ppo_Trained_1.mat', 'agent3_ppo_Trained_1.mat', 'agent4_ppo_Trained_1.mat', ...
    'agent1_ppo_Trained_2.mat', 'agent2_ppo_Trained_2.mat', 'agent3_ppo_Trained_2.mat', 'agent4_ppo_Trained_2.mat'
};

% Initialize variables for storing evaluation metrics
metrics = struct('Regret', [], 'SampleComplexity', [], 'ComputationalComplexity', [], 'EmpiricalPerformance', [], 'Convergence', []);

% Initialize Excel file to store results
resultsFile = 'agent_evaluation_results.xlsx';
headers = {'Agent', 'Algorithm', 'Regret', 'SampleComplexity', 'ComputationalComplexity', 'EmpiricalPerformance', 'Convergence'};
xlswrite(resultsFile, headers, 'Sheet1', 'A1');

% Loop over DQN agent models
for i = 1:length(dqn_agent_files)
    % Load DQN agent model
    model = load(dqn_agent_files{i});
    
    % Evaluate the model (you should implement the actual evaluation functions)
    regret = evaluateRegret(model);
    sampleComplexity = evaluateSampleComplexity(model);
    computationalComplexity = evaluateComputationalComplexity(model);
    empiricalPerformance = evaluateEmpiricalPerformance(model);
    convergence = evaluateConvergence(model);
    
    % Store the results
    metrics.Regret(i) = regret;
    metrics.SampleComplexity(i) = sampleComplexity;
    metrics.ComputationalComplexity(i) = computationalComplexity;
    metrics.EmpiricalPerformance(i) = empiricalPerformance;
    metrics.Convergence(i) = convergence;
    
    % Write results to Excel
    agentName = strcat('DQN_Agent_', num2str(i));
    xlswrite(resultsFile, {agentName, 'DQN', regret, sampleComplexity, computationalComplexity, empiricalPerformance, convergence}, 'Sheet1', strcat('A', num2str(i+1)));
end

% Loop over PPO agent models
for i = 1:length(ppo_agent_files)
    % Load PPO agent model
    model = load(ppo_agent_files{i});
    
    % Evaluate the model (you should implement the actual evaluation functions)
    regret = evaluateRegret(model);
    sampleComplexity = evaluateSampleComplexity(model);
    computationalComplexity = evaluateComputationalComplexity(model);
    empiricalPerformance = evaluateEmpiricalPerformance(model);
    convergence = evaluateConvergence(model);
    
    % Store the results
    metrics.Regret(i + length(dqn_agent_files)) = regret;
    metrics.SampleComplexity(i + length(dqn_agent_files)) = sampleComplexity;
    metrics.ComputationalComplexity(i + length(dqn_agent_files)) = computationalComplexity;
    metrics.EmpiricalPerformance(i + length(dqn_agent_files)) = empiricalPerformance;
    metrics.Convergence(i + length(dqn_agent_files)) = convergence;
    
    % Write results to Excel
    agentName = strcat('PPO_Agent_', num2str(i));
    xlswrite(resultsFile, {agentName, 'PPO', regret, sampleComplexity, computationalComplexity, empiricalPerformance, convergence}, 'Sheet1', strcat('A', num2str(i+length(dqn_agent_files)+1)));
end

% --- Evaluate Regret ---
function regret = evaluateRegret(model)
    % Define the optimal policy or baseline
    optimalPolicy = loadOptimalPolicy();  % Implement this function based on your problem
    agentActions = simulateAgentActions(model);
    
    % Regret is the difference in performance from the optimal policy
    regret = sum(abs(agentActions - optimalPolicy));
end

% --- Evaluate Sample Complexity ---
function sampleComplexity = evaluateSampleComplexity(model)
    % Check if the 'episodes' or 'numEpisodes' field exists in the model
    if isfield(model, 'episodes')
        sampleComplexity = model.episodes;
    elseif isfield(model, 'numEpisodes')
        sampleComplexity = model.numEpisodes;
    else
        warning('No episode field found in the model.');
        sampleComplexity = NaN;  % Return NaN if no field is found
    end
end

% --- Evaluate Computational Complexity ---
function computationalComplexity = evaluateComputationalComplexity(model)
    % Measure training time or computational load (e.g., based on steps or processing time)
    tic;
    simulateAgentActions(model);  % Measure inference time (e.g., for a full episode)
    computationalComplexity = toc;
end

% --- Evaluate Empirical Performance ---
function empiricalPerformance = evaluateEmpiricalPerformance(model)
    % Simulate the agent's performance and track the health improvements
    % Example: Track how the patient's condition improves (e.g., from Chronic to Healthy)
    patientState = simulatePatientState(model);  % Implement this simulation
    empiricalPerformance = measureHealthImprovement(patientState);
end

% --- Evaluate Convergence ---
function convergence = evaluateConvergence(model)
    % Check if the model has a 'lossHistory' field or similar
    if isfield(model, 'lossHistory')
        lossHistory = model.lossHistory;  % Assuming the loss history is stored during training
        convergence = abs(lossHistory(end) - lossHistory(end-1));  % The change in loss
    else
        warning('No loss history found in the model.');
        convergence = NaN;  % Return NaN if no loss history is found
    end
end

% --- Helper function to simulate agent actions ---
function actions = simulateAgentActions(model)
    % Simulate the actions taken by the agent for evaluation (you should implement this)
    actions = rand(1, 10);  % Dummy values for now
end

% --- Helper function to simulate patient state ---
function patientState = simulatePatientState(model)
    % Simulate how the agent affects the patient state (e.g., health condition)
    patientState = rand(1, 10);  % Dummy values for now
end

% --- Helper function to measure health improvement ---
function healthImprovement = measureHealthImprovement(patientState)
    % Measure the improvement (e.g., from chronic to healthy)
    healthImprovement = sum(patientState);  % Dummy logic for now
end

% --- Helper function to load optimal policy ---
function optimalPolicy = loadOptimalPolicy()
    optimalPolicy = rand(1, 10);  % Dummy optimal policy
end

% Visualization (plot performance metrics)
figure;
subplot(3, 2, 1);
bar(metrics.Regret);
title('Regret');
xlabel('Agent');
ylabel('Regret');

subplot(3, 2, 2);
bar(metrics.SampleComplexity);
title('Sample Complexity');
xlabel('Agent');
ylabel('Episodes/Steps');

subplot(3, 2, 3);
bar(metrics.ComputationalComplexity);
title('Computational Complexity');
xlabel('Agent');
ylabel('Time (Seconds)');

subplot(3, 2, 4);
bar(metrics.EmpiricalPerformance);
title('Empirical Performance');
xlabel('Agent');
ylabel('Health Improvement');

subplot(3, 2, 5);
bar(metrics.Convergence);
title('Convergence');
xlabel('Agent');
ylabel('Change in Loss');
