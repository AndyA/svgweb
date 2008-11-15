/*
Copyright (c) 2008 James Hight
Copyright (c) 2008 Richard R. Masters, for his changes.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

package com.zavoo.svg.nodes.mask
{
    import com.zavoo.svg.nodes.SVGClipPathNode;
    import com.zavoo.svg.nodes.SVGNode;
    import com.zavoo.svg.nodes.SVGRoot;
    import com.zavoo.svg.nodes.mask.SVGMask;
    import com.zavoo.svg.nodes.SVGFilterNode;
    
    import flash.events.Event;
    import flash.geom.Matrix;
    

    public class SVGClipMaskParent extends SVGNode
    {

        protected var _childToMaskXML:XML;
        protected var _childCopyNode:SVGNode;

        public function SVGClipMaskParent(svgRoot:SVGRoot, 
                                          childToMaskXML:XML):void {
            this._childToMaskXML = childToMaskXML;
            super(svgRoot, this._childToMaskXML);
        }    


        override protected function parse():void {
            var svgMask:SVGMask;
            var clipList:XMLList;
            var childNode:SVGNode;
            var clipPathXML:XML;

            clipList = this._childToMaskXML.attribute('clip-path');
            var clipPath:String = clipList[0].toString();
            clipPath = clipPath.replace(/url\(#(.*?)\)/si,"$1");

            // Create and add the mask node
            var clipPathNode:SVGClipPathNode = this.svgRoot.getElement(clipPath);
            if (clipPathNode) {
                clipPathXML = clipPathNode.xml.copy();

                if (this._childToMaskXML.@['transform'] is String) {
                    //this.svgRoot.debug("Using transform on clip: " +  this._childToMaskXML.@['transform']);
                    clipPathXML.@['transform'] = this._childToMaskXML.@['transform'];
                }
                //this.svgRoot.debug("Using clippath mask: " + clipPathXML.toString());
                svgMask = new SVGMask(this.svgRoot, clipPathXML);
                this.addChild(svgMask);
                this.mask = svgMask;

                 
                var childNodeXML:XML = this._childToMaskXML.copy();
                delete childNodeXML.@['clip-path'];

                childNode = this.parseNode(childNodeXML);
                if (childNode) {
                    this.addChild(childNode);
                }
            }
            else {
                // disabled because clippaths always seem to be previously declared
                // in <defs> sections
                // xxx would need to create random id if necessary.
                //this.svgRoot.addReference(this.xml.@id, clipPath);

                //this.svgRoot.debug("Clippath " + clipPath
                //             + " not (yet?) available for mask node " + this.xml.@id);
            }

        }

        override protected function setupFilters():void {
        }

        override protected function transformNode():void {
            this.transform.matrix = new Matrix();
        }

        override protected function generateGraphicsCommands():void {
            //Do Nothing
            this._graphicsCommands = new Array();
        }

        override protected function registerId(event:Event):void {
            this.removeEventListener(Event.ADDED, registerId);
        }
    }
}
