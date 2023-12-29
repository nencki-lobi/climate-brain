function out = count_cet_trials(customfile)

    % Read custom file

    C = readtable(customfile, 'ReadVariableNames', false);
    C.Properties.VariableNames = {'Code', 'Response'};

    % Define trial types

    dummy = C(startsWith(C.Code, 'dl') | startsWith(C.Code, 'dr'), :);

    rational = C((contains(C.Code, 'c0') & ~contains(C.Code, 'm0')) | ...
                  (contains(C.Code, 'm0') & ~contains(C.Code, 'c0')), :);

    lonely = C(matches(C.Code, 'c0_m0'), :);

    CET = setdiff(C, [dummy; rational; lonely]);

    % Identify egoistic, altruistic, correct dummy & correct rational trials

    CET.Egoistic(startsWith(CET.Code,'m') & matches(CET.Response,'LEFT')) = 1;
    CET.Egoistic(startsWith(CET.Code,'c') & matches(CET.Response,'RIGHT')) = 1;

    CET.Altruistic(startsWith(CET.Code,'c') & matches(CET.Response,'LEFT')) = 1;
    CET.Altruistic(startsWith(CET.Code,'m') & matches(CET.Response,'RIGHT')) = 1;

    dummy.Correct(startsWith(dummy.Code,'dl') & matches(dummy.Response,'LEFT')) = 1;
    dummy.Correct(startsWith(dummy.Code,'dr') & matches(dummy.Response,'RIGHT')) = 1;

    rational.Correct(startsWith(rational.Code,'c0') & matches(rational.Response,'RIGHT')) = 1;
    rational.Correct(startsWith(rational.Code,'m0') & matches(rational.Response,'RIGHT')) = 1;
    rational.Correct(endsWith(rational.Code,'c0') & matches(rational.Response,'LEFT')) = 1;
    rational.Correct(endsWith(rational.Code,'m0') & matches(rational.Response,'LEFT')) = 1;
    
    % Calculate metrics of interest

    isEgoistic = sum(CET.Egoistic); %/ 25;
    isAltruistic = sum(CET.Altruistic); %/ 25;
    correctDummy = sum(dummy.Correct); %/ 12;
    correctRational = sum(rational.Correct); %/ 10;

    % Return output

    out = {isEgoistic, isAltruistic, correctDummy, correctRational};

end