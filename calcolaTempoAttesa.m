function [minutiAttesa, repartoAssegnato] = calcolaTempoAttesa(codiceColore, sintomi)
% Algoritmo di simulazione dinamica delle risorse ospedaliere

%% DEFINIZIONE DELLO STATO DEI REPARTI (Stanze, Medici, Occupazione)

reparti.Cardiologia = struct('MediciInTurno', 2, 'StanzeTotali', 3,  'StanzeOccupate', randi([0, 3]));
reparti.Medicina    = struct('MediciInTurno', 4, 'StanzeTotali', 10, 'StanzeOccupate', randi([5, 10]));
reparti.Pediatria   = struct('MediciInTurno', 2, 'StanzeTotali', 4,  'StanzeOccupate', randi([1, 4]));

sintomiLower = lower(sintomi);

%%  ASSEGNAZIONE AUTOMATICA DEL REPARTO IN BASE AI SINTOMI
if contains(sintomiLower, 'pediatria') || contains(sintomiLower, 'bambino') || contains(sintomiLower, 'neonato')
    repartoAssegnato = 'Pediatria';
elseif contains(sintomiLower, 'toracico') || contains(sintomiLower, 'cuore') || contains(sintomiLower, 'arresto') || strcmpi(codiceColore, 'Rosso')
    repartoAssegnato = 'Cardiologia';
else
    repartoAssegnato = 'Medicina';
end

% Estraiamo le risorse correnti del reparto scelto
res = reparti.(repartoAssegnato);

%% 3. CALCOLO STATISTICO DEL TEMPO DI ATTESA IN CODA
% Logica: Più stanze sono occupate, più si aspetta. Più medici ci sono, più la coda scorre veloce.

% Calcoliamo il tasso di saturazione delle stanze (da 0 a 1)
saturazioneStanze = res.StanzeOccupate / res.StanzeTotali;

% Tempo base in minuti determinato dal Codice Colore 
switch codiceColore
    case 'Rosso'
        minutiAttesa = 0; % Emergenza assoluta: nessuna attesa, salta la coda
        return;           
    case 'Giallo'
        tempoBase = 15;   % Target medico standard: 15 min
    case 'Verde'
        tempoBase = 60;   % Target medico standard: 60 min
    otherwise
        tempoBase = 30;
end

% Algoritmo della Coda Simulata:
% Moltiplichiamo il tempo base per l'indice di saturazione delle stanze
% e lo dividiamo per il numero di medici attivi in quel turno.
% Aggiungiamo una componente casuale per simulare l'imprevedibilità del PS.

if res.StanzeOccupate >= res.StanzeTotali
    % Se il reparto è pieno, scatta un malus di attesa
    moltiplicatoreCoda = 2.5; 
else
    moltiplicatoreCoda = 1 + (saturazioneStanze * 1.5);
end

% Formula finale del tempo di attesa stimato
minutiAttesa = (tempoBase * moltiplicatoreCoda) / res.MediciInTurno;

% Aggiunta di rumore casuale di simulazione (+/- 5 minuti) per realismo grafico
minutiAttesa = minutiAttesa + randi([-5, 5]);

% Protezione matematica: l'attesa per i gialli/verdi non può essere inferiore a 2 minuti
if minutiAttesa < 2
    minutiAttesa = 2;
end

minutiAttesa = round(minutiAttesa);
end
