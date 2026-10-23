/**
 * 
 * Class to hold and update command line argument data.
 *  Multiple arguments for a flag must be non-space delimited, and 
 *   handled externally to this parser.
 * 
 * Includes methods for:
 *      i). Broad getters/setters for argData map.
 *      ii). Updating argData with provided command-line arguments.
 *      iii). Getting active arguments.
 *      iv). Getting argument values.
 * 
 * To do:
 *      i). Action scoped arguments (like username for CRUD)?
 * 
 */

class Parser{

    // Constructor
    constructor() {
        this.argData = new Map( [
            [ "Description", "" ],
            [ "Actions", new Map() ],
            [ "Global Arguments", new Map() ]
        ]);
    }


    /*
    *
    * Setters and droppers for args, actions, action-args
    *  
    */

    // Set description
    setDescription(description) {
        this.argData.set("Description", description);
    }

    // Add an argument <= Maybe have thing to manage --Value -V/v
    addArg(arg, arg_descript, argKeys) {

        // Pass if argument exists
        if ( this.argData.get("Global Arguments").has(arg) ) {
            console.log(`Error, ${arg} already present in object`);

        } else{

            // Otherwise create
            this.argData.get("Global Arguments").set("State", "Expected");
            this.argData.get("Global Arguments").set(arg, new Map());
            this.argData.get("Global Arguments").get(arg).set("State", "Expected");
            this.argData.get("Global Arguments").get(arg).set("Description", arg_descript);
            this.argData.get("Global Arguments").get(arg).set("Keys", new Map());
            this.argData.get("Global Arguments").get(arg).get("Keys").set("search", argKeys.split(","));
            this.argData.get("Global Arguments").get(arg).get("Keys").set("value", null);
        }
        
    }

    // Drop argument
    dropArgument(arg) {
        this.argData.get("Global Arguments").delete(arg);
    }

    // Add action
    addAction(action, arg, arg_descript, argKeys) {

        // Handle creating first
        if ( this.argData.get("Actions").has(action) ) {
            
            // Add argument to action
            this.argData.get("Actions").get(action).set(arg, new Map());
            this.argData.get("Actions").get(action).get(arg).set("State", "Expected");
            this.argData.get("Actions").get(action).get(arg).set("Description", arg_descript);
            this.argData.get("Actions").get(action).get(arg).set("Keys", new Map());
            this.argData.get("Actions").get(action).get(arg).get("Keys").set("search", argKeys.split(","));
            this.argData.get("Actions").get(action).get(arg).get("Keys").set("value", null);

        } else{

            // Add the action map, then add arg + description to that key
            this.argData.get("Actions").set(action, new Map() );
            this.argData.get("Actions").get(action).set("State", "Expected");
            this.argData.get("Actions").get(action).set(arg, new Map());
            this.argData.get("Actions").get(action).get(arg).set("State", "Expected");
            this.argData.get("Actions").get(action).get(arg).set("Description", arg_descript);
            this.argData.get("Actions").get(action).get(arg).set("Keys", new Map());
            this.argData.get("Actions").get(action).get(arg).get("Keys").set("search", argKeys.split(","));
            this.argData.get("Actions").get(action).get(arg).get("Keys").set("value", null);
        }
    }

    // Drop action
    dropAction(action) {
        this.argData.get("Actions").delete(action);
    }

    // Drop argument from action
    dropArgAction(action, arg) {
        this.argData.get("Actions").get(action).delete(arg);
    }


    /*
     * 
     * Getters
     * 
     */

    // Get description
    getDescription() {
        return this.argData.get("Description");
    }

    // Get global arguments
    getGlobalArguments(){
        return this.argData.get("Global Arguments");
    }

    // Get actions
    getActions() {
        return this.argData.get("Actions");
    }

    // Get argument
    getArgument(arg) {
        return this.argData.get("Global Arguments").get(arg);
    }

    // Get action
    getAction(action) {
        return this.argData.get("Actions").get(action);
    }

    // Get arg in action
    getActionArg(action, arg) {
        return this.argData.get("Actions").get(action).get(arg);
    }


    /**
     * 
     * Setting arguments from command line argv
     * 
     */

    // Set global variables
    updateGlobalVariables(){

        // Initalize variables
        let argInd;
        let i, j, argUpdated;

        // Get global arguments
        for (i of this.getGlobalArguments().keys() ){

            // Skip 
            if (i != "State") {

                // Scan the argv list for the search keys of active argument
                for(j of this.getArgument(i).get("Keys").get("search")){

                    // Only self if the search is present
                    argInd = process.argv.indexOf(j);
                    if(argInd >= 0) {
                        this.getArgument(i).get("Keys").set("value", process.argv[argInd+1] );
                        this.getArgument(i).set("State", 1);
                        argUpdated = 1;
                    }
                    
                }
            }
        }

        // Note that global arguments has been set at least once
        if (argUpdated == 1){
            this.argData.get("Global Arguments").set("State", 1);
        }

    }

    // Update action argument
    updateActionArgs() {

        // Scan each action present in argv
        for ( let action of this.getActions().keys() ) {
            let actionInd = process.argv.indexOf(action);
            if( actionInd != -1 ){
        
                /// Set state from expected to assigned
                this.getAction(action).set("State", 1);

                // Slice argv and search it for arguments
                for (let argument of this.getAction(action).keys()){
                    if (argument != "State") {
                        for (let j of this.getActionArg(action, argument).get("Keys").get("search")){
                            let argInd = process.argv.indexOf(j);
                            if ( argInd >= 0 ) {
                                this.getActionArg(action, argument).get("Keys").set("value", process.argv[argInd+1]);
                                this.getActionArg(action, argument).set("State", 1);
                            }
                        }
                    }
                }   
            }
        }
    }

    /**
     * 
     * Get active actions, arguments
     * 
     */

    // Get active global args
    getActiveGlobalArgs(){

        // Initalize variables
        let args = [];

        // Determine active actions
        for (let arg of this.getGlobalArguments().keys() ) {
            
            // Pass if key is state
            if ( arg != "State") {

                // Add if active
                if (this.getArgument(arg).get("State") == 1) {
                    args.push(arg);
                }

            }
            
        }

        // Return list
        return args;
    }

    // Get active actions
    getActiveActions(){

        // Determine active actions
        let actions = [];
        for (let action of this.getActions().keys() ) {
            if (this.getAction(action).get("State") == 1) {
                actions.push(action);
            }
        }

        // Return active actions
        return actions;
    }


    // Get active action arguments
    getActiveActionArgs(action){

        // Determine active arguments of an action
        let actionArgs = [];
        for (let arg of this.getAction(action).keys()){

            // Pass on action 
            if (arg != "State") {
                if (this.getActionArg(action, arg).get("State") == 1 ) {
                    actionArgs.push(arg);
                }
            }
            
        }

        // Return actions active arguments
        return actionArgs;
    }


    /**
     * 
     * Get values for arguments (global, action)
     * 
     */

    // Get value for global argument
    getGlobalArgumentValue(arg){

        // Initialize variables
        let argValue;

        // Handle undefined value
        if (this.getActiveGlobalArgs().indexOf(arg) >= 0 ){
            argValue = this.getArgument(arg).get("Keys").get("value");
        } else {
            argValue = "null";
        }

        // Return value
        return argValue;

    }

    // Get value of argument in action
    getActionArgValue(action, arg) {

        // Initialize return
        let argValue

        // Handle undefined
        if ( this.getActiveActionArgs(action).indexOf(arg) >= 0 ) {
            argValue = this.getActionArg(action, arg).get("Keys").get("value");
        } else {
            argValue = "null";
        }

        // Return argValue
        return argValue;
    }
}

// Export class
module.exports = Parser ;