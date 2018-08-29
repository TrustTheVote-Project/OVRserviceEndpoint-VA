require 'sinatra'

post '/Voter/Confirmation' do
  request.body.rewind
  json = JSON.parse request.body.read
  
  Post.create!(request: json, endpoint: "VoterConfirmationRequest", query_string: params, headers: request.env)
  is_error = json["LastName"].to_s.downcase == "error"
  is_protected = json["LastName"].to_s.downcase == "protected"
  if !is_error
    if is_protected
      {
        "IsProtected" => true,
        "VoterID" => json["FirstName"].to_s.downcase == "voter" ? "123456789" : nil,
        "IsRegisteredVoter" => json["FirstName"].to_s.downcase == "voter",
        "TransactionTimestamp" => Time.now.iso8601,
        "HasDMVSignature" => json["DriversLicenseNo"].to_s.downcase.starts_with?("t")
      }.to_json
    else
      {
        "VoterID" => json["FirstName"].to_s.downcase == "voter" ? "123456789" : nil,
        "IsRegisteredVoter" => json["FirstName"].to_s.downcase == "voter",
        "TransactionTimestamp" => Time.now.iso8601,
        "HasDMVSignature" => json["DriversLicenseNo"].to_s.downcase.starts_with?("t")
      }.to_json
    end
  else
   {}.to_json 
  end
end
# Request:
# LastName
# FirstName
# MiddleName
# SSN9
# DOBYear (4)
# DOBDay (2)
# DOBMonth (2)
# DriversLicenseNo
# LocalityName
# Format (=JSON)

# Respsonse
# VoterID (9)
# IsRegisteredVoter (bool)
# If true, voter is a registered voter match. Protected voters will not return a match and will be required to register by paper method.
# TransactionTimestamp (datetime) Date formatted to use the ISO 8601 format with the UTC offset.
# HasDMVSignature (bool)  Confirmation that user has DMV signature. Must send Driver’s license number to return this value. Not needed for voter confirmations only.

post '/Voter/Submit' do
  request.body.rewind
  json = JSON.parse request.body.read
  
  Post.create!(request: json, endpoint: "VoterRegistrationSubmission", query_string: params, headers: request.env)
  is_error = json["VoterRegistrations"][0]["LastName"] == "Error"
  if !is_error
  '{"TransactonId":0,"TransactionTimestamp":"2018-08-23T12:46:27.3851675-04:00","TransactionErrorMessage":"String","VoterRegistrationsAccepted":0,"VoterRegistrationsWithErrors":0,"Errors":[{"ErrorId":0,"ErrorTimestamp":"2018-08-23T12:46:27.3851675-04:00","VoterSubmissionId":"String","ErrorMessage":"String","FieldErrors":[{"FieldName":"String","Issue":"String"}]}],"Confirmations":[{"ConfirmationId":999,"ConfirmationTimestamp":"2018-08-23T12:46:27.3851675-04:00","VoterSubmissionId":"String","ErrorMessage":"String"}]}'
  else
    '{"TransactonId":0,"TransactionTimestamp":"2018-08-23T12:46:27.3851675-04:00","TransactionErrorMessage":"String","VoterRegistrationsAccepted":0,"VoterRegistrationsWithErrors":0,"Errors":[{"ErrorId":0,"ErrorTimestamp":"2018-08-23T12:46:27.3851675-04:00","VoterSubmissionId":"String","ErrorMessage":"String","FieldErrors":[{"FieldName":"String","Issue":"String"}]}],"Confirmations":[]}'
  end
end

  # Response:
  # VoterID
  # string
  # 9
  # Voter Identification number will be null if IsRegisteredVoter is false.
  # 2
  # IsRegisteredVoter
  # bool
  # Yes
  # If true, voter is a registered voter match. Protected voters will not return a match and will be required to register by paper method.
  # 3
  # TransactionTimestamp
  # datetime
  # 40
  # Yes
  #
  # Date formatted to use the ISO 8601 format with the UTC offset.
  # 4
  # HasDMVSignature
  #
  # Confirmation that user has DMV signature. Must send Driver’s license number to return this value. Not needed for voter confirmations only.


get "/" do
  @posts = Post.order("created_at DESC")
  erb :"posts/index"
end