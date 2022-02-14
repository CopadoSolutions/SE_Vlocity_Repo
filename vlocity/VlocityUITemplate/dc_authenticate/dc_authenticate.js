vlocity.cardframework.registerModule.controller('dcAuthenticateController', ['$scope', function($scope) {
    digitalCommerceSDK = null;
    $scope.signUp = true;
    $scope.loadingApiCall = false;
    $scope.signInDetails = { UserName: "", Password: "" };
    $scope.signUpDetails = {
        firstName: "",
        lastName: "",
        phone: "",
        email: "",
        password: ""
    };

    $scope.initialiseSDK = function() {
        debugger;
        this.bpTree.response.login = "no";
        this.bpTree.response.billingAddress = "no";
        this.bpTree.response.paymentDone = "no";
        digitalCommerceSDK = this.getSDKInstance();
    }

    $scope.showSpinner = function() {
        return $scope.loadingApiCall;
    }

    $scope.getValidEmail = function(email) {
        const re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        const isValid = re.test(String(email).toLowerCase());
        return isValid ? email : null;
    }

    $scope.initLogin = function() {
        $scope.signUp = (this.bpTree.response.Authenticate && this.bpTree.response.Authenticate.PersonalDetails=="yes")?true:false;
        $scope.signInDetails = Object.assign({},this.bpTree.response.Authenticate.Login);
        $scope.signUpDetails = Object.assign({},this.bpTree.response.Authenticate.Register);

        if($scope.signUp && $scope.getValidEmail($scope.signUpDetails.email)) {
            var input = $scope.signUpGetInput();
            $scope.signUpSDKCall(input);
        }
        else if(!$scope.signUp && $scope.getValidEmail($scope.signInDetails.UserName)) {
            var input = $scope.signInGetInput();
            $scope.signInSDKCall(input);
        }
    }

    $scope.signUpGetInput = function() {
        return Object.assign(
        digitalCommerceSDK.createAuthenticateUserInput(),
        {
            email: $scope.signUpDetails.email,
            password: $scope.signUpDetails.password,
            signUp: true,
            phoneNumber: $scope.signUpDetails.phone,
            firstName: $scope.signUpDetails.firstName,
            lastName: $scope.signUpDetails.lastName
        });
    }
    $scope.signUpSDKCall = function(input) {
        $scope.loadingApiCall = true;
        this.bpTree.response.login = "yes";
        digitalCommerceSDK
        .authenticateUser(input)
        .then(response => {
            $scope.loadingApiCall = false;
            this.bpTree.response.Authenticate.email = input.email;
            this.bpTree.response.Authenticate.name = response.name;
            this.autoAdvance("next");
        })
        .catch(error => {
            $scope.loadingApiCall = false;
            console.log('SignUp Failed');
        });
    }
    $scope.signInGetInput = function() {
        return Object.assign(
        digitalCommerceSDK.createAuthenticateUserInput(),
        {
            email: $scope.signInDetails.UserName,
            password: $scope.signInDetails.Password
        }
        );
    }
    $scope.signInSDKCall = function(input) {
        $scope.loadingApiCall = true;
        this.bpTree.response.login = "yes";
        digitalCommerceSDK
        .authenticateUser(input)
        .then(response => {
            $scope.loadingApiCall = false;
            this.bpTree.response.Authenticate.email = input.email;
            this.bpTree.response.Authenticate.name = response.name;
            this.autoAdvance("next");
        })
        .catch(error => {
            $scope.loadingApiCall = false;
            console.log('SignIn Failed');
        });
    }

    // load the SDK
    $scope.initialiseSDK();
}]);