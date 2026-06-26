classdef applicazionebottone < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './applicazionebottone.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        StoricoTable                   matlab.ui.control.Table
        AVVIAButton                    matlab.ui.control.Button
        CODICELamp                     matlab.ui.control.Lamp
        CODICELampLabel                matlab.ui.control.Label
        IndicazionidelsistemaTextArea  matlab.ui.control.TextArea
        TextArea2Label                 matlab.ui.control.Label
        SintomienotemedicheTextArea    matlab.ui.control.TextArea
        TextAreaLabel                  matlab.ui.control.Label
        PAmmHgEditField                matlab.ui.control.NumericEditField
        PAmmHgEditFieldLabel           matlab.ui.control.Label
        FCbpmEditField                 matlab.ui.control.NumericEditField
        FCbpmEditFieldLabel            matlab.ui.control.Label
        SATURAZIONEO2Gauge             matlab.ui.control.Gauge
        SATURAZIONEO2GaugeLabel        matlab.ui.control.Label
        ETEditField                    matlab.ui.control.NumericEditField
        ETEditFieldLabel               matlab.ui.control.Label
        NOMEECOGNOMEEditField          matlab.ui.control.EditField
        NOMEECOGNOMEEditFieldLabel     matlab.ui.control.Label
        CODICEFISCALEEditField         matlab.ui.control.EditField
        CODICEFISCALEEditFieldLabel    matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods

        % Button pushed function: AVVIAButton
        function AVVIAButtonPushed(app, event)
            % Callback function: AVVIAButton
function AVVIAButtonPushed(app, event)
    % 1. Recupera i dati inseriti e forza la conversione in testo standard
    cf_paziente      = char(app.CODICEFISCALEEditField.Value);
    sat              = app.SATURAZIONEO2Gauge.Value; 
    fc               = app.FCbpmEditField.Value;
    pa               = app.PAmmhgEditField.Value;    
    sintomi_correnti = char(app.SintomienotemedicheTextArea.Value); 

    if isempty(cf_paziente) || length(cf_paziente) < 16
        app.IndicazionidelsistemaTextArea.Value = "ERRORE: Inserire un Codice Fiscale valido di 16 caratteri.";
        return;
    end

    %% CALCOLO AUTOMATICO DELL'ETÀ DAL CODICE FISCALE
    try
        anno_cf = str2double(cf_paziente(7:8));
        anno_corrente = 2026; 
        if anno_cf > 26
            anno_nascita = 1900 + anno_cf;
        else
            anno_nascita = 2000 + anno_cf;
        end
        eta_calcolata = anno_corrente - anno_nascita;
        % Aggiorna automaticamente la casella ETÀ sullo schermo!
        app.ETEditField.Value = eta_calcolata;
    catch
        eta_calcolata = 30; 
    end

    % 2. Connessione al Database MySQL
    percorso_driver = '/home/ginevra/mysql-connector-j-8.4.0.jar';
    if ~any(strcmp(javaclasspath, percorso_driver))
        javaaddpath(percorso_driver);
    end
    
    username = 'root';
    password = 'Ginevra_.dr05';
    url = 'jdbc:mysql://localhost:3306/bio_progetto_db?allowPublicKeyRetrieval=true&useSSL=false';
    
    allergieDB = '';
    storicoDB = '';
    
    try
        props = java.util.Properties();
        props.setProperty('user', username);
        props.setProperty('password', password);
        driver = javaObject('com.mysql.cj.jdbc.Driver');
        conn = driver.connect(url, props);
        
        if ~isempty(conn)
            stmt = conn.createStatement();
            
            % Cerca se il paziente esiste già nel DB
            query_cerca = ['SELECT Allergie, StoricoClinico FROM Pazienti WHERE CodiceFiscale = ''' cf_paziente ''''];
            rs = stmt.executeQuery(query_cerca);
            
            if rs.next()
                allergieDB = char(rs.getString('Allergie'));
                storicoDB = char(rs.getString('StoricoClinico'));
            else
                % Inserisce il nuovo paziente usando l'età estratta dal CF
                query_ins = ['INSERT INTO Pazienti (CodiceFiscale, NomeCognome, Eta, Allergie, StoricoClinico) VALUES (''' ...
                            cf_paziente ''', ''Paziente Anonimo'', ' num2str(eta_calcolata) ', '''', '''')'];
                stmt.executeUpdate(query_ins);
            end
            rs.close();
            
            %% AGGIORNAMENTO DELLA TABELLA STORICA DA DATABASE
            query_storico_triage = ['SELECT DataOra, CodiceAssegnato, Sintomi FROM Triage WHERE FK_Paziente = ''' cf_paziente ''' ORDER BY DataOra DESC'];
            rs_storico = stmt.executeQuery(query_storico_triage);
            
            dati_tabella = {};
            while rs_storico.next()
                dati_tabella = [dati_tabella; {char(rs_storico.getString('DataOra')), char(rs_storico.getString('CodiceAssegnato')), char(rs_storico.getString('Sintomi'))}];
            end
            rs_storico.close();
            
            % Se ci sono record passati, li spinge dentro la tua UITable grafica

            if ~empty(dati_tabella)
                app.StoricoTable.Data = dati_tabella;
            else
                app.StoricoTable.Data = {}; % Svuota se non ha storico
            end
            
            %% 3. Calcolo del Triage tramite la tua funzione logica
            [codiceColore, indicazioni] = valutaTriage(sat, fc, pa, sintomi_correnti, allergiesDB, storicoDB);
            
            %% 4. Aggiornamento dell'Interfaccia Grafica e Allarme Acustico
            app.IndicazionidelsistemaTextArea.Value = indicazioni;
            
            switch codiceColore
                case 'Rosso'
                    app.CODICELamp.Color = [1 0 0];   
                    % Riproduce un avviso sonoro d'emergenza medico
                    fs = 8000; t = 0:1/fs:0.25;
                    suono = [sin(2*pi*880*t), sin(2*pi*440*t), sin(2*pi*880*t)];
                    sound(suono, fs);
                case 'Giallo'
                    app.CODICELamp.Color = [1 0.8 0]; 
                case 'Verde'
                    app.CODICELamp.Color = [0 1 0];   
                otherwise
                    app.CODICELamp.Color = [0.5 0.5 0.5]; 
            end
            
            %% 5. Salvataggio definitivo del Triage corrente su MySQL
            query_salva = ['INSERT INTO Triage (FK_Paziente, FrequenzaCardiaca, PressioneSistolica, SaturazioneOssigeno, Sintomi, CodiceAssegnato) VALUES (''' ...
                           cf_paziente ''', ' num2str(fc) ', ' num2str(pa) ', ' num2str(sat) ', ''' sintomi_correnti ''', ''' codiceColore ''')'];
            stmt.executeUpdate(query_salva);
            
            stmt.close();
            conn.close();
        end
    catch ME
        app.IndicazionidelsistemaTextArea.Value = "Errore: " + ME.message;
    end
end
        end
    end

end