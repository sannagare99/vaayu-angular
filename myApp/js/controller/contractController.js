app.controller('contractCtrl', function ($scope, $http, $state, $stateParams) {
  
  $scope.tab = $stateParams.paramOne;
  $scope.fileObject;
  $scope.ctype;
  $scope.bcycle;
  $scope.siteList;
  $scope.selectedSiteId;
  $scope.selectedUIDs=[];
  $scope.uniqueId=[
    {
      "name":"Trip Category",
      "value":"trip_category"
      },
        
      {
      "name":"Vehicle Category",
      "value":"vehicle_category"
      },
      {
      "name":"Vehicle Model",
      "value":"vehicle_model"
      },
      {
      "name":"Age of Vehicle",
      "value":"age_of_vehicle"
      },
      {
      "name":"Trip Time",
      "value":"trip_time"
      },
      {
      "name":"From to To Time",
      "value":"from_time_to_time"
      },
      {
      "name":"KM",
      "value":"trip_km"
      },
      {
      "name":"Trip Date",
      "value":"trip_date"
      },
      {
      "name":"AC/ Non AC",
      "value":"ac_nonac"
      },
      {
      "name":"Shift",
      "value":"shift"
      },
      {
      "name":"Zone",
      "value":"zone"
      },
      {
      "name":"Trip Type",
      "value":"trip_type"
      },
      {
      "name":"Garage KM",
      "value":"garage_km"
      },
      {
      "name":"Swing KM",
      "value":"swing_km"
      },  
      
      {
      "name":"Trip Day",
      "value":"day_type"
      },
      {
      "name":"Number of employees",
      "value":"employee_count"
      },
      {
      "name":"Vehicle Capacity",
      "value":"vehicle_capacity"
      },
      {
      "name":"Vehicle Average",
      "value":"vehicle_avg"
      },
      {
      "name":"Guard",
      "value":"guard"
      },      
  ]
  $scope.billingOption=[
    {
      "name":"Per Trip",
      "value":"Per Trip"
      },
        
      {
      "name":"Daily",
      "value":"Daily"
      },
      {
      "name":"Weekly",
      "value":"Weekly"
      },
      {
      "name":"Forth Nightly",
      "value":"Forth Nightly"
      },
      {
      "name":"Monthly",
      "value":"Monthly"
      },
      {
      "name":"Quarterly",
      "value":"Quarterly"
      }
  ]
  $scope.submitResponse;
  $scope.expanded = true;
  $scope.totalSelectedUIDs="Select UIDs";
  $scope.selectedUIDtoSend;

this.$onInit = function () {
    $scope.totalSelectedUIDs="Select UIDs";
   $scope.showCheckboxes();
   
    $scope.fetchSiteList();
    
    $scope.tab = $stateParams.paramOne;
    console.log( $scope.tab);
    // $scope.tab = 'CUSTOMER';
    
  };
$scope.closeExpanded=()=>{
  console.log('exp')
  checkboxes.style.display = "none";
  $scope.expanded = false;
}
$scope.showCheckboxes=()=> {
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
  $scope.totalSelectedUIDs=$scope.selectedUIDs.length+' UIDs selected';
  console.log($scope.selectedUIDs);
};
  $scope.fetchSiteList = () => {
       
    $http({
        method: 'POST',
        url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8001/api/v1/getAllSiteList',
        headers: {
          'Content-Type': 'application/json',
          'uid': 'deekshithmech@gmail.com',
          'access_token': 'h-Hen_PE9YDkOTa-HLjMVw',
          'client': 'A50BtzCIieAvpcTk2450ew'
        },
        data: { test: 'test' }
       })
    .then(function(res) { 
        if (res.data['success']) {
             $scope.siteList = res.data.data.list;
           // $scope.$broadcast('onSiteListReceived',res.data.data.list);
            console.log(JSON.stringify($scope.siteList))
        } else {
            alert(res.data['message']);
        }

    }).catch(err => {
        console.log(err)
    });

    
};



  $scope.fileNameChanged = function (e) {
    console.log(e.files)
    $scope.fileObject = e.files[0];
    console.log(e, $scope.fileObject)

  }

  $scope.downloadCSV = function () {
    $http({
        method: 'GET',
        url: 'http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8003/api/v1/contract/download-samplefile',
        headers: {
          'Content-Type': 'application/json',
          'uid': 'deekshithmech@gmail.com',
          'access_token': 'h-Hen_PE9YDkOTa-HLjMVw',
          'client': 'A50BtzCIieAvpcTk2450ew'
        },

      })
      .then(function (response) {
        console.log(JSON.stringify(response))
      });
    console.log('download CSV');
  }

  $scope.createContract = function () {
    // var file=$scope.myFile;
    $scope.selectedUIDtoSend = $scope.selectedUIDs.map(({ value }) => value)
    console.log($scope.selectedUIDtoSend);
    var formData = new FormData();
    formData.append("customer_id", "1");
    formData.append("site_id", $scope.selectedSiteId);
    formData.append("unique_identification[]", $scope.selectedUIDtoSend);
    formData.append("billig_cycle", $scope.bcycle);
    formData.append("contract_type", $scope.ctype);
    formData.append("contract_file", $scope.fileObject);
    console.log(formData)
    var contractType="contract";
    if($scope.tab=='BA'){
      contractType='bacontract'
    }
    var request = new XMLHttpRequest();
    var vm=$scope;
    request.open("POST", "http://ec2-13-233-214-215.ap-south-1.compute.amazonaws.com:8003/api/v1/"+contractType+"/upload");
    request.onload = function () {
      if (request.readyState === request.DONE) {
          if (request.status === 200) {
              console.log(request.response);
             vm.submitResponse=request.response;
              

          }
      }
  };
  console.log($scope.submitResponse)
    request.send(formData);
    
  
  }

  
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
 

  $scope.reset = function () {
    $state.reload(true);
  }

  

  $scope.setTab = function (tabId) {
    console.log('set tabbed');
    $scope.tab = tabId;
  };

  $scope.isSet = function (tabId) {
    return $scope.tab === tabId;
  };
});