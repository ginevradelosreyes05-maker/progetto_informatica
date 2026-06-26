function [codiceColore, indicazioni] = valutaTriage(sat, fc, pa, sintomi, allergieStoriche, patologieStoriche)

    % Inizializziamo con il codice verde
    codiceColore = 'Verde';
    indicazioni = "Parametri stabili. Monitoraggio standard in sala d'attesa.";
    avvisoSicurezza = "";

    % Trasformiamo tutto in minuscolo per evitare problemi con le maiuscole
    sintomiLower = lower(sintomi);
    allergieLower = lower(allergieStoriche);
    storicoLower = lower(patologieStoriche);

    % Controllo farmaci / allergie
    elencoAllergie = split(allergieLower, ','); % Separa le allergie se inserite con la virgola
    for i = 1:length(elencoAllergie)
        allergiaSingola = strip(elencoAllergie{i}); 
        if ~isempty(allergiaSingola) && contains(sintomiLower, allergiaSingola)
            avvisoSicurezza = avvisoSicurezza + sprintf("\n[ATTENZIONE] Rilevato potenziale rischio: la nota corrente contiene '%s', a cui il paziente è ALLERGICO!", allergiaSingola);
        end
    end

    %Controllo sintomi / storico Clinico
    if contains(storicoLower, 'ipertensione') && (pa > 160)
        avvisoSicurezza = avvisoSicurezza + "\n[AVVISO CLINICO] Paziente iperteso cronico con crisi pressoria in corso.";
    end
    if contains(storicoLower, 'diabete') && (contains(sintomiLower, 'confusione') || contains(sintomiLower, 'malore'))
        avvisoSicurezza = avvisoSicurezza + "\n[AVVISO CLINICO] Paziente diabetico con sintomi neurologici/aspecifici: verificare glicemia immediatamente.";
    end

    % CODICE ROSSO
    if (sat < 90)
        codiceColore = 'Rosso';
        indicazioni = "CRITICO: Grave ipossia. Somministrare ossigeno immediatamente.";
        indicazioni = aggiungiDettagli(indicazioni, sintomi, allergieStoriche, patologieStoriche, avvisoSicurezza);
        return; 
    end
    if (fc < 40 || fc > 130)
        codiceColore = 'Rosso';
        indicazioni = "CRITICO: Alterazione estrema del ritmo cardiaco. Rischio arresto.";
        indicazioni = aggiungiDettagli(indicazioni, sintomi, allergieStoriche, patologieStoriche, avvisoSicurezza);
        return;
    end
    if (pa < 80 || pa > 200)
        codiceColore = 'Rosso';
        indicazioni = "CRITICO: Shock o crisi ipertensiva acuta. Monitoraggio continuo.";
        indicazioni = aggiungiDettagli(indicazioni, sintomi, allergieStoriche, patologieStoriche, avvisoSicurezza);
        return;
    end
    if contains(sintomiLower, 'arresto') || contains(sintomiLower, 'incoscienza') || contains(sintomiLower, 'dolore toracico forte')
        codiceColore = 'Rosso';
        indicazioni = "CRITICO: Sintomatologia ad alto rischio evolutivo. Sala rossa.";
        indicazioni = aggiungiDettagli(indicazioni, sintomi, allergieStoriche, patologieStoriche, avvisoSicurezza);
        return;
    end

    % CODICE GIALLO
    if (sat >= 90 && sat <= 94)
        codiceColore = 'Giallo';
        indicazioni = "URGENTE: Insufficienza respiratoria moderata.";
    end
    if ((fc >= 40 && fc <= 49) || (fc >= 111 && fc <= 130))
        codiceColore = 'Giallo';
        indicazioni = "URGENTE: Bradicardia/Tachicardia moderata. Eseguire ECG.";
    end
    if ((pa >= 80 && pa <= 89) || (pa >= 161 && pa <= 200))
        codiceColore = 'Giallo';
        indicazioni = "URGENTE: Alterazione moderata della pressione arteriosa.";
    end
    if contains(sintomiLower, 'dolore') || contains(sintomiLower, 'dispnea') || contains(sintomiLower, 'febbre alta')
        codiceColore = 'Giallo';
        indicazioni = "URGENTE: Sintomatologia rilevante. Rivalutazione a breve.";
    end

    % Indicazioni codici gialli e verdi
    indicazioni = aggiungiDettagli(indicazioni, sintomi, allergieStoriche, patologieStoriche, avvisoSicurezza);

end 

% Funzione per formattazione del report
function testoCompleto = aggiungiDettagli(baseTesto, sintomi, allergie, storico, avvisi)
    testoCompleto = string(baseTesto);
    
    % Avvisi di sicurezza 
    if avvisi ~= ""
        testoCompleto = testoCompleto + "\n" + avvisi;
    end
    
    % Dati inseriti a punti elenco 
    if ~isempty(sintomi) && ~strcmpi(sintomi, '')
        testoCompleto = testoCompleto + sprintf("\n- Sintomi correnti: %s", sintomi);
    end
    if ~isempty(allergie) && ~strcmpi(allergie, '') && ~strcmpi(allergie, 'nessuna')
        testoCompleto = testoCompleto + sprintf("\n- Allergie note: %s", allergie);
    end
    if ~isempty(storico) && ~strcmpi(storico, '')
        testoCompleto = testoCompleto + sprintf("\n- Anamnesi/Storico: %s", storico);
    end
end 