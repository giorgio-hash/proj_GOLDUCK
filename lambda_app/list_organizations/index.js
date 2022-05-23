const AWS = require('aws-sdk');
const s3 = new AWS.S3();

const parser = require('xml-js');

exports.handler = async (event) => {
  var i = 0;
  var results;
  try {
    results = await s3download(event.queryStringParameters.id);
  } catch (error) {
    console.log(error);
    return sendRes(404, error);
  }

  while (true) { // itera finchè s3 non restituisce il file in modo corretto
    try {
      var xml = JSON.parse(parser.xml2json(results.Body.toString('utf-8'), {
        compact: true,
        ignoreComment: true,
        spaces: 2
      }));
      break;
    } catch (err) {
      results = await s3download(event.queryStringParameters.id);
    }

  }

  var list = []
  if(xml.ResultList.ClassResult.PersonResult)
    list.push(xml.ResultList.ClassResult.PersonResult.Organisation.Name._text);
  else
    for(let i=0 ; i < xml.ResultList.ClassResult.length ; i++ )
      if(xml.ResultList.ClassResult[i].PersonResult.Organisation)
        list.push(xml.ResultList.ClassResult[i].PersonResult.Organisation.Name._text);
      else
        for(let j=0; j < xml.ResultList.ClassResult[i].PersonResult.length ; j++ )
           list.push(xml.ResultList.ClassResult[i].PersonResult[j].Organisation.Name._text);
         
         
  var uniqueArray = list.filter(function(elem, pos) {
    return list.indexOf(elem) == pos;
    });

  return sendRes(200, JSON.stringify(uniqueArray));

};

/*
ClassResult.Class.Name
*/

const sendRes = (status, body) => {
  var response = {
    statusCode: status,
    headers: {
       "Content-Type" : "application/json", 
            "Access-Control-Allow-Origin" : "*",
            "X-Requested-With" : "*"
    },
    body: body
  };
  return response;
};

async function s3download(id) {
  var params = {
    Bucket: 'secchiellobello',
    Key: 'results-' + id + '.xml'
  };

  var results = await s3.getObject(params, function (err, data) {
    if (err) {
      console.log('Error', err);
    } else {
      return data;
    }
  }).promise();
  return results;
}
