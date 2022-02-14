/**
 * This template allows you to customize the behaviour of the OmniScript File input compoment by parsing any uploaded files and inserting
 * the processed content back into the OmniScript data.  The code assumes the incoming file is a CSV file, but this template could be 
 * modified to support virtually any other format as needed.
 * 
 * Currently only supports single file uploads
 * 
 * @author Joe McMaster (jmcmaster@vlocity.com)
 * 
 * @version 1.1
 * 
 * History
 * =======
 * Oct 24, 2019 - v1.0 - Initial version by Joe supporting CSV files
 * May 27, 2020 - v1.1 - Fixed issue where corresponding Selectable Items was not displaying in Live mode (was fine in Preview mode)
 * 
 */
var osDataDestination = "importSites";   // Where in the OmniScript the parsed data will be inserted

// CSV Setup
var csvHeader = true;             // indication if the CSV file contains a header

/**
 * Parses Comma-Delimited content and returns a list of of fields as an array.  Will return
 * null if the CSV string is not well formed.
 * 
 * @param text  The raw text to parse
 * 
 * @return An array values or null if the incoming text is not well formed
 * 
 * @see https://stackoverflow.com/questions/8493195/how-can-i-parse-a-csv-string-with-javascript-which-contains-comma-in-data
 */
function CSVtoArray(text) {

    var re_valid = /^\s*(?:'[^'\\]*(?:\\[\S\s][^'\\]*)*'|"[^"\\]*(?:\\[\S\s][^"\\]*)*"|[^,'"\s\\]*(?:\s+[^,'"\s\\]+)*)\s*(?:,\s*(?:'[^'\\]*(?:\\[\S\s][^'\\]*)*'|"[^"\\]*(?:\\[\S\s][^"\\]*)*"|[^,'"\s\\]*(?:\s+[^,'"\s\\]+)*)\s*)*$/;
    var re_value = /(?!\s*$)\s*(?:'([^'\\]*(?:\\[\S\s][^'\\]*)*)'|"([^"\\]*(?:\\[\S\s][^"\\]*)*)"|([^,'"\s\\]*(?:\s+[^,'"\s\\]+)*))\s*(?:,|$)/g;
    // Return NULL if input string is not well formed CSV string.
    if (!re_valid.test(text)) return null;
    var a = [];                     // Initialize array to receive values.
    text.replace(re_value, // "Walk" the string using replace with callback.
        function(m0, m1, m2, m3) {
            // Remove backslash from \' in single quoted values.
            if      (m1 !== undefined) a.push(m1.replace(/\\'/g, "'"));
            // Remove backslash from \" in double quoted values.
            else if (m2 !== undefined) a.push(m2.replace(/\\"/g, '"'));
            else if (m3 !== undefined) a.push(m3);
            return ''; // Return empty string.
        });
    // Handle special case of empty last value.
    if (/,\s*$/.test(text)) a.push('');
    return a;
};

/**
 * Processes a file after it has been uploaded
 * 
 * @param event  The FileReader upload event
 * 
 * @return A list of entries parsed from the file content
 */
function processContent(event) {

    // List of parsed rows
    resultSet = [];

    // Track the column headers (if any)
    headers = [];

    // Split into rows
    let rows =  event.target.result.split(/\r?\n/);
    for (let i=0; i<rows.length; i++) {

        let row = rows[i];
        if (row && row.trim().length !== 0) {

            // Parse the row
            let values = CSVtoArray(row);

            // Assume the first row is the header, unless header=false is set            
            if (csvHeader && i === 0) headers = values;
            else {

                // Check for inconsistencies (if we have headers)
                if (csvHeader && headers.length !== values.length) {

                    console.error("Failed to process row " + i + ", number of headers do not match number of fields:");
                    console.error("Headers (" + headers.length + ") -> " + headers);
                    console.error("Row     (" + values.length + ") -> " + values);
                }
                else {

                    // Generate the JSON Object which will be added to the list of objects stored in OmniScript
                    let entry = {};
                    for (let x=0; x<values.length; x++) {

                        // Use the header name if we have headers, otherwise dynamically generate a name (i.e. column1, column2, etc.)
                        if (csvHeader) entry[headers[x]] = values[x];
                        else entry['column' + (x+1)] = values[x];
                    }
                    resultSet.push(entry);
                }
            }
        }
    }

    return resultSet;
};

/**
 * Saves the Result data to the OmniScript JSON structure
 * 
 * @param data  A list of entries parsed from the file content
 * @param scp   The Angular Scope of the HTML element
 */
function saveResults(data, scp) {

	if (data) {
		
	    // Build and apply the update to the OmniScript data
	    // The update is in the form StepX:FileUpload:
	    let toSet = data;
	    let namePath = osDataDestination.split(/[:\.]/);
	    for (var i = namePath.length - 1; i >= 0; i--) {
	        var newSet = {};
	        newSet[namePath[i]] = toSet;
	        toSet = newSet;
	    }
	    scp.applyCallResp(toSet);
	    
	    // Force a refresh on the AngularJS scope.
	    // The corresponding Selectable Items that will show these results will sometimes
	    // fail to display anything when the OS is running in live mode (works fine in Preview mode)
	    // Likely some sort of timing issue ... maybe this is heavy-handed but it works.
	    scp.$apply();
	}
};

/**
 * Triggered when a file upload is initiated in an OmniScript step
 * 
 * @param scp  The Angular Scope of the HTML element
 */
baseCtrl.prototype.loadFile = function(scp) {

    // Support multiple-files uploaded at once
    let locationFiles = document.getElementById(scp.control.name).files;
    for (var i=0; i<locationFiles.length; i++) {
        
        // Create a reader for this file and the file processing function to execute once the upload has completed
        var reader = new FileReader();
        reader.onload = function(event) {
            
            // Process the File Content and save the results to OmniScript
            saveResults(processContent(event), scp);
        };

        // Basic error handling
        reader.onerror = function(event) {

            console.error("File could not be read! Code " + event.target.error.code);
        };

        // Start reading the file
        reader.readAsText(locationFiles[i]);
    }
};