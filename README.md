# AS3Communicator
AS3Communicator lets you connect your AS3 application's DisplayList to the outside world like JavaScript

## How to use?
At the very beginning of your code, you need to insert the following line:
<code>this.stage.addChild(new AS3Communicator());</code>
This is all you need to do, to implement it in your project.

## How does it work?
AS3Communicator will automatically register into your web-based AS3 application's HTML DOM tree.
You can access it via the javascript variable $flash.
Let's try something: Open your favorite browser and open the developer console.
Type $flash.help(); and hit enter.
You will be presented with the whole API that you can use to access Flash DisplayObjects via JavaScript.

## Find an object on stage
There are several ways to find objects in the display list:
### FQI (Fully Qualified Identifier)
This will return a JSON object with the textfield's properties.
$flash.findObjectByName('buttonPanel.ok_button.textfield');

### Simple Identifier
This method should only be used on unique names. AS3Communicator will search the 'whole' display tree recursively for this object.
$flash.findObjectByName('myAwesomeObject');

### Array Access
Let's assume you have a panel with a set of 5 buttons and the button names are assigned randomly. How would you find the 4th button in this panel?
$flash.findObjectByName('buttonPanel[3]');

Now let's assume on the root of the stage are 3 buttonPanels that can be in different positions and their names are assigned randomly. You want to find the 1st button on the 2nd panel.
$flash.findObjectByName('[1][0]');

## Get an object property
You want to find out if a button is visible?
$flash.getObjectProperty('container.button', 'visible');

## Set an object property
You want to change the text of a button?
$flash.setObjectProperty('container.button.textfield', 'text', 'Buttons are awesome!');
// update the width as well
var intTextWidth = $flash.getObjectProperty('container.button.textfield', 'width');
$flash.setObjectProperty('container.button', 'width' intTextWidth + 20);

## Tools
There are also some useful tools, like printing the current cursor position and highlighting of objects. Look at the help() method and try them out!
