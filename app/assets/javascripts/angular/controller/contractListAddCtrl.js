app.controller('contractListAddCtrl', function ($scope, $http, $state, SessionService, ToasterService, $location, $timeout) {

    this.$onInit = function () {
        console.log('onit - contractListAddCtrl');
        $scope.totalSelectedUIDs = "Select UIDs";
        $scope.showCheckboxes();

        $scope.fetchSiteList();
        $scope.fetchBAList();

        $scope.tab = 'CUSTOMER';
        console.log($scope.tab);
        
    };

    $scope.fileObject;
    $scope.ctype;
    $scope.bcycle;
    $scope.siteList;
    $scope.selectedSiteId;
    $scope.selectedUIDs = [];


    $scope.contract_type = [
        { name: 'PER KM',   value: 'Per km' },
        { name: 'PER HEAD', value: 'Per head', },
        { name: 'PER ZONE', value: 'Per zone', },
        { name: 'PER SLAB', value: 'Per slab', },
        { name: 'PER PACKAGE', value: 'Per package', }
    ];

    $scope.uniqueId = [
        {
            "name": "Trip Category",
            "value": "trip_category"
        },

        {
            "name": "Vehicle Category",
            "value": "vehicle_category"
        },
        {
            "name": "Vehicle Model",
            "value": "vehicle_model"
        },
        {
            "name": "Age of Vehicle",
            "value": "age_of_vehicle"
        },
        {
            "name": "Trip Time",
            "value": "trip_time"
        },
        {
            "name": "From to To Time",
            "value": "from_time_to_time"
        },
        {
            "name": "KM",
            "value": "trip_km"
        },
        {
            "name": "Trip Date",
            "value": "trip_date"
        },
        {
            "name": "AC/ Non AC",
            "value": "ac_nonac"
        },
        {
            "name": "Shift",
            "value": "shift"
        },
        {
            "name": "Zone",
            "value": "zone"
        },
        {
            "name": "Trip Type",
            "value": "trip_type"
        },
        {
            "name": "Garage KM",
            "value": "garage_km"
        },
        {
            "name": "Swing KM",
            "value": "swing_km"
        },

        {
            "name": "Trip Day",
            "value": "day_type"
        },
        {
            "name": "Number of employees",
            "value": "employee_count"
        },
        {
            "name": "Vehicle Capacity",
            "value": "vehicle_capacity"
        },
        {
            "name": "Vehicle Average",
            "value": "vehicle_avg"
        },
        {
            "name": "Guard",
            "value": "guard"
        },
    ]
    $scope.billingOption = [
        // {"name": "Per Trip", "value": "Per Trip"},
        { "name": "Daily", "value": "Daily" },
        // { "name": "Weekly", "value": "Weekly" },
        // { "name": "Forth Nightly",  "value": "Forth Nightly" },
        { "name": "Monthly",  "value": "Monthly" },
        // {  "name": "Quarterly", "value": "Quarterly"  }
    ]
    $scope.submitResponse;
    $scope.expanded = true;
    $scope.totalSelectedUIDs = "Select UIDs";
    $scope.selectedUIDtoSend;


    $scope.closeExpanded = () => {
        console.log('exp')
        checkboxes.style.display = "none";
        $scope.expanded = false;
    }
    $scope.showCheckboxes = () => {
        var checkboxes = document.getElementById("checkboxes");
        if (!$scope.expanded) {
            checkboxes.style.display = "block";
            $scope.expanded = true;
        } else {
            checkboxes.style.display = "none";
            $scope.expanded = false;
        }
    }
    $scope.toggleSelection = function toggleSelection(UID) {
        var idx = $scope.selectedUIDs.indexOf(UID);

        // Is currently selected
        if (idx > -1) {
            $scope.selectedUIDs.splice(idx, 1);
        }

        // Is newly selected
        else {
            $scope.selectedUIDs.push(UID);
        }
        $scope.totalSelectedUIDs = $scope.selectedUIDs.length + ' UIDs selected';
        console.log($scope.selectedUIDs);
    };
    $scope.fetchSiteList = () => {

        $http({
            method: 'POST',
            url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8001/api/v1/getAllSiteList',
            headers: {
                'Content-Type': 'application/json',
                'uid': SessionService.uid,
                'access_token': SessionService.access_token,
                'client': SessionService.client
            },
            data: { test: 'test' }
        })
            .then(function (res) {
                if (res.data['success']) {
                    $scope.siteList = res.data.data.list;
                    // $scope.$broadcast('onSiteListReceived',res.data.data.list);
                    console.log(JSON.stringify($scope.siteList))
                } else {
                    ToasterService.showError('Error', res.data['message']);
                }

            }).catch(err => {
                ToasterService.showError('Error', 'Something went wrong, Try again later.');
                console.log(err)
            });

    };

    $scope.onFileSelected = () => {
        console.log($scope.selectedFile)
    }

    $scope.fileNameChanged = function (e) {
        console.log(e.files)
        $scope.fileObject = e.files[0];
        console.log(e, $scope.fileObject)
        $timeout(() => {
            $scope.tempfileName = $scope.fileObject.name
            console.log($scope.tempfileName)
        }, 200)
    }

    $scope.downloadCSV = function () {
        $http({
            method: 'GET',
            url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8003/api/v1/contract/download-samplefile',
            headers: {
                'Content-Type': 'application/json',
                'uid': SessionService.uid,
                'access_token': SessionService.access_token,
                'client': SessionService.client
            },

        })
            .then(function (response) {
                console.log(JSON.stringify(response))
            });
        console.log('download CSV');
    }
    
    $scope.isValid = () => {
        $scope.selectedUIDtoSend = $scope.selectedUIDs.map(({ value }) => value)
        if ($scope.selectedUIDtoSend.length == 0) {
            ToasterService.showError('Error', 'Select one or more UDID\'s');
            return false;
        } else if (!$scope.selectedSiteId && $scope.tab == 'CUSTOMER') {
            ToasterService.showError('Error', 'Select Site');
            return false;
        } else if (!$scope.baID && $scope.tab == 'BA') {
            ToasterService.showError('Error', 'Select BA');
            return false;
        } else if (!$scope.bcycle) {
            ToasterService.showError('Error', 'Select Billing Cycle.');
            return false;
        } else if (!$scope.ctype) {
            ToasterService.showError('Error', 'Select Contract Type.');
            return false;
        } else if (!$scope.fileObject) {
            ToasterService.showError('Error', 'Upload contract in csv');
            return false;
        }
        return true;
    }

    $scope.createContract = function () {
        $scope.tempfileName = 'atul jadhav'
        // var file=$scope.myFile;
        if (!$scope.isValid()) {
            return;
        }
        $scope.selectedUIDtoSend = $scope.selectedUIDs.map(({ value }) => value)
        console.log($scope.selectedUIDtoSend);

        

        var formData = new FormData();
        formData.append("customer_id", "1");
        console.log($scope.selectedUIDtoSend);
        formData.append("unique_identification", $scope.selectedUIDtoSend);
        formData.append("billig_cycle", $scope.bcycle);
        formData.append("contract_type", $scope.ctype);
        formData.append("contract_file", $scope.fileObject);
        formData.append("site_id", $scope.selectedSiteId);
        console.log(formData)
        var contractType = "contract";
        if ($scope.tab == 'BA') {
            formData.append("ba_id", $scope.baID);
            contractType = 'bacontract'
        } 
        var request = new XMLHttpRequest();
        var vm = $scope;
        // request.open("POST", "http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8003/api/v1/" + contractType + "/upload");
        request.open("POST", "http://5be4a49e.ngrok.io/api/v1/" + contractType + "/upload");
        request.onload = function () {
            console.log(request.response);
            if (request.readyState === request.DONE) {
                if (request.status === 200) {
                    // console.log(request.response);
                    vm.submitResponse = request.response;                    
                    ToasterService.showSuccess('Success', 'Contract created successfully.');
                    console.log('Contract created successfully.');
                    $scope.getContracts();
                }
            } else {
                ToasterService.showError('Error', 'Something went wrong, Try again later.');
            }
        };
        request.send(formData);
    }

    $scope.reset = function () {
        $state.reload(true);
    }



    $scope.setTab = function (tabId) {
        console.log('set tabbed');
        $scope.tab = tabId;
        $scope.getContracts();
    };

    $scope.isSet = function (tabId) {
        return $scope.tab === tabId;
    };


    $scope.contracts = [{
        cust_id: "23412355-2",
        site: "Adam Denisov",
        file_name: "File Name.csv",
    },
    {
        cust_id: "23412355-2",
        site: "Adam Denisov",
        file_name: "File Name.csv",
    },
    {
        cust_id: "23412355-2",
        site: "Adam Denisov",
        file_name: "File Name.csv",
    },
    {
        cust_id: "23412355-2",
        site: "Adam Denisov",
        file_name: "File Name.csv",
    },
    {
        cust_id: "23412355-2",
        site: "Adam Denisov",
        file_name: "File Name.csv",
    },
    {
        cust_id: "23412355-2",
        site: "Adam Denisov",
        file_name: "File Name.csv",
    },

    ]


    $scope.getContracts = () => {
        console.log($scope.selectedSiteId)
        var urlEnd = $scope.selectedSiteId;
        if ($scope.tab === 'BA') {
            urlEnd = $scope.baID;
        }
        let url = 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com/getContractListByCustId?custId=1&custType=' + $scope.tab + '&siteId=' + urlEnd;
        // let url = 'http://4607df07.ngrok.io/api/v1/getContractListByCustId?custId=1&custType=' + $scope.tab + '&siteId=' + urlEnd;
        console.log(url)
        $http({
            method: 'GET',
            url: url,
            headers: {
                'Content-Type': 'application/json',
                'uid': SessionService.uid,
                'access_token': SessionService.access_token,
                'client': SessionService.client
            },
            data: { test: 'test' }
        }).then(function (res) {
            console.log(res)
            if (res.data['success']) {
                $scope.contractList = res.data.data;
                // $scope.$broadcast('onSiteListReceived',res.data.data.list);
                console.log(JSON.stringify($scope.contractList))
                
            } else {
                ToasterService.showError('Error', res.data['message']);
            }

        }).catch(err => {
            console.log(err)
            ToasterService.showError('Error', 'Something went wrong, Try again later.');
        });
    }

    $scope.downloadSampleFile = () => {
        console.log($scope.selectedSiteId );
        if (!$scope.selectedSiteId && $scope.tab === 'CUSTOMER') {
            ToasterService.showError('Error', 'Please select site name');
            return;
        }
        
        if (!$scope.baID && $scope.tab === 'BA') {
            ToasterService.showError('Error', 'Please select BA name');
            return;
        }
        let id = $scope.selectedSiteId;
        let type = "SITE";
        if ($scope.tab == 'BA') {
            id = $scope.baID;
            type = 'BA'
        } 
        var a = document.createElement("a");
        let url = 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8003/api/v1/contract/download-samplefile/'+id+'/'+type
        a.href = url;
        a.download = 'contract_sample.xlsx';
        a.click();   
    }

    $scope.fetchBAList = () => {

        $http({
            method: 'POST',
            url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com/induction/getAllBaList',
            headers: {
                'Content-Type': 'application/json',
                'uid': SessionService.uid,
                'access_token': SessionService.access_token,
                'client': SessionService.client
            },
            data: { test: 'test' }
        })
            .then(function (res) {
                if (res.data['success']) {
                    $scope.baList = res.data.data.list;
                    // $scope.$broadcast('onSiteListReceived',res.data.data.list);
                    console.log(JSON.stringify($scope.baList))
                } else {
                    ToasterService.showError('Error', res.data['message']);
                }

            }).catch(err => {
                ToasterService.showError('Error', 'Something went wrong, Try again later.');
                console.log(err)
            });

    };


    $scope.getSelectedBA = () => {
        var name = 'NA';
        angular.forEach($scope.baList,function(item,idx,shiftArray){
            if(item.id == $scope.baID){
              name = item.legal_name;
            }
        });
        return name;
    }

});