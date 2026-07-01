function creaDatabase()
    db_file = 'database_ospedale.mat';
    
    if exist(db_file, 'file')
        disp('Il database esiste già.');
        return;
    end
    
    try
        % Creiamo la struttura vuota della tabella PAZIENTE
        PAZIENTE = table([], [], [], [], [], 'VariableNames', ...
            {'CodiceFiscale', 'NomeCognome', 'Eta', 'Allergie', 'StoricoClinico'});
        
        % Creiamo la struttura vuota della tabella TRIAGE
        TRIAGE = table([], [], [], [], [], [], [], [], [], 'VariableNames', ...
            {'FK_Paziente', 'FrequenzaCardiaca', 'PressioneSistolica', 'SaturazioneOssigeno', 'Sintomi', 'CodiceAssegnato', 'DataOra', 'RepartoAssegnato', 'MinutiAttesa'});
        
        % Salviamo entrambe le tabelle dentro l'unico file database relazionale .mat
        save(db_file, 'PAZIENTE', 'TRIAGE');
        disp('Database relazionale "database_ospedale.mat" inizializzato con successo!');
    catch ME
        error('Errore nella creazione del database: %s', ME.message);
    end
end