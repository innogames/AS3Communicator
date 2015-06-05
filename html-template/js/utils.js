function simpleTestCase()
{
    var buttonWidth         = index.getObjectProperty('instance15', 'width');
    var textWidth           = index.getObjectProperty('instance16', 'width');
    var clearButtonChild    = index.findObject('clearButton.Button TextField');

    console.log('clearButton.Button TextField: '+ clearButtonChild);

    if(buttonWidth < textWidth)
    {
        console.log('Test failed - text wider than button.');
        return 'fail';
    }

    //change the text :)
    index.setObjectProperty('instance16', 'text', 'Hello World! The quick brown fox is lazy!');

    buttonWidth = index.getObjectProperty('instance15', 'width');
    textWidth = index.getObjectProperty('instance16', 'width');

    if (buttonWidth < textWidth) {
        console.log('Test failed - text wider than button.');
        return 'fail';
    }

    return 'success';
}


function isReady()
{
    console.log("JavaScript isReady");
    return true;
}

function getConsoleTextLength()
{
    var json = index.f();
    var jsonObject = JSON.parse(json);

    for(var idx in jsonObject.elements)
    {
        var objCurrent = jsonObject.elements[idx];
        if(objCurrent.type === 'flash.text::TextField')
        {
            if(objCurrent.properties.name === 'console')
            {
                console.log('Flash console text length: '+ objCurrent.properties.length);
                return objCurrent.properties.length;
            }
        }
    }
}

function findObject(objectName)
{
    var json = index.f();
    var jsonObject = JSON.parse(json);

    for (var idx in jsonObject.elements) {
        var objCurrent = jsonObject.elements[idx];
         if (objCurrent.properties.name === objectName)
         {
              console.log('Flash console text length: ' + objCurrent.properties.length);
              return objCurrent;
         }
    }
}

function getPropertyFromObject(objectName, propertyName)
{
    var obj = findObject(objectName);
    return obj.properties[propertyName];
}

function listPropertiesOfObject(objectName)
{
    return findObject(objectName).properties;
}

function clickObject(objectName)
{
    index.clickObject(objectName);
}

function clickAtPosition(x,y)
{
    index.clickAtPosition(x,y);
}
