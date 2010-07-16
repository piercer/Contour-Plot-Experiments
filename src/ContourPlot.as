package
{

	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	[SWF(height="600",width="600")]
	public class ContourPlot extends Sprite
	{

		private static const WIDTH:Number = 600;
		private static const HEIGHT:Number = 600;
		private static const NPOINTS:Number = 15;

		private var _data:Array;
		private var _zmax:Number;
		private var _zmin:Number;
		
		public function ContourPlot()
		{
			_data = [];
			for (var i:uint=0;i<NPOINTS;i++)
			{
				_data[i]=[];
				for (var j:uint=0;j<NPOINTS;j++)
				{
					var d:Number=Math.sqrt((i-50)*(i-50)+(j-50)*(j-50));
					var d2:Number=Math.sqrt((i-150)*(i-150)+(j-50)*(j-50));
					_data[i][j] = Math.sin(d*Math.PI/10)*200+Math.cos(d2*Math.PI/10)*200;
				}
			}
			plotContours(10);
		}
		
		private function plotContours(nContours:uint):void
		{
			var i:uint;
			var j:uint;
			var k:uint;
			var x:Number;
			var y:Number;
			var gradient:Number;
			
			var dx:Number = WIDTH/(NPOINTS-1);
			var dy:Number = HEIGHT/(NPOINTS-1);
			
			_zmin=_data[0][0];
			_zmax=_zmin;
			
			for (i=0;i<NPOINTS;i++)
			{
				for (j=0;j<NPOINTS;j++)
				{
					var z:Number = _data[i][j];
					if (z<_zmin)
					{
						_zmin=z;
					}
					if (z>_zmax)
					{
						_zmax=z;
					}
				}
			}
			
			var contourStep:Number = (_zmax-_zmin)/nContours;
			var contourValues:Vector.<Number> = new Vector.<Number>(nContours);
			for (i=0;i<nContours;i++)
			{
				contourValues[i]=_zmin+i*contourStep;
			}
			
			var g:Graphics = graphics;
			g.beginFill(0xEEEEEE,1);
			g.drawRect(0,0,WIDTH,WIDTH);
			g.endFill();
			g.lineStyle(1,0xCCCCCC);
			
			for (i=0;i<NPOINTS;i++)
			{
				x=i*dx;
				g.moveTo(x,0);
				g.lineTo(x,HEIGHT);
			}
			for (i=0;i<NPOINTS;i++)
			{
				y=i*dy;
				g.moveTo(0,y);
				g.lineTo(WIDTH,y);
			}
			for (i=0;i<NPOINTS;i++)
			{
				x=i*dx;
				for (j=0;j<NPOINTS;j++)
				{
					y=j*dy;
					g.moveTo(x,y);
					g.lineTo(x+dx,y+dy);
					g.moveTo(x+dx,y);
					g.lineTo(x,y+dy);
				}
			}
			
//			var slices:Vector.<Sprite> = new Vector.<Sprite>(nContours);
//			for (i=0;i<nContours;i++)
//			{
//				var slice:Sprite = new Sprite();
//				addChild(slice);
//				slice.cacheAsBitmap=true;
//				slices[i]=slice;
//				slice.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
//				slice.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
//			}

			for (i=0;i<NPOINTS-1;i++)
			{
				
				var im:Number = i+0.5;
				var x20:Number = i*dx;
				var x31:Number = x20+dx;
				
				for (j=0;j<NPOINTS-1;j++)
				{
					
					var p0:Number = _data[i][j];
					var p1:Number = _data[i+1][j];
					var p2:Number = _data[i][j+1];
					var p3:Number = _data[i+1][j+1];
					var p4:Number = (p0+p1+p2+p3)/4;
					var jm:Number = j+0.5;
					var y10:Number = j*dy;
					var y32:Number = y10+dy;
					
					var dp04:Number = p0-p4;
					var dp14:Number = p1-p4;
					var dp24:Number = p2-p4;
					var dp34:Number = p3-p4;
					var dp20:Number = p2-p0;
					var dp10:Number = p1-p0;
					var dp31:Number = p3-p1;
					var dp32:Number = p3-p2;

					for (k=0;k<nContours;k++)
					{
						//g=slices[k].graphics;
						g=graphics;
						g.lineStyle(1,0x000000);

						var contourValue:Number = contourValues[k];

						var dp0:Number = contourValue-p0;
						var dp1:Number = contourValue-p1;
						var dp2:Number = contourValue-p2;
						var dp4:Number = 0.5*(contourValue-p4);
						
						var d04:Number = dp4/dp04;
						var d14:Number = dp4/dp14;
						var d24:Number = dp4/dp24;
						var d34:Number = dp4/dp34;
						
						var d20:Number = dp0/dp20;
						var d10:Number = dp0/dp10;
						var d31:Number = dp1/dp31;
						var d32:Number = dp2/dp32;
												
						var x24:Number = (im-d24)*dx;
						var y24:Number = (jm+d24)*dy;
						
						var x34:Number = (im+d34)*dx;
						var y34:Number = (jm+d34)*dy;
						var x14:Number = (im+d14)*dx;
						var y14:Number = (jm-d14)*dy;
						var x04:Number = (im-d04)*dx;
						var y04:Number = (jm-d04)*dy;
						
						var x32:Number = (i+d32)*dx;
						var y31:Number = (j+d31)*dy;
						var y20:Number = (j+d20)*dy;
						var x10:Number = (i+d10)*dx;

						var intersection:uint;
						//
						//triangle 1
						//
						renderTriangle(p0,p4,p2,contourValue,x20,y20,x04,y04,x24,y24,g);
						//
						//triangle 2
						//
						renderTriangle(p0,p4,p1,contourValue,x10,y10,x04,y04,x14,y14,g);
						//
						//triangle 3
						//
						renderTriangle(p1,p4,p3,contourValue,x31,y31,x14,y14,x34,y34,g);
						//
						//triangle 4
						//
						renderTriangle(p2,p4,p3,contourValue,x32,y32,x24,y24,x34,y34,g);
					}
				}
			}
			
		}

		private function onMouseOut(event:MouseEvent):void
		{
			var slice:Sprite = Sprite(event.target);
			slice.alpha=1;			
		}

		private function onMouseOver(event:MouseEvent):void
		{
			var slice:Sprite = Sprite(event.target);
			slice.alpha=0.5;
		}

		private function renderTriangle(p0:Number, p1:Number, p2:Number, contourValue:Number, x02:Number, y02:Number, x01:Number, y01:Number, x12:Number, y12:Number, g:Graphics):void
		{
			var x1:Number;
			var y1:Number;
			var x2:Number;
			var y2:Number;
			var intersection:uint = getTriangleIntersectionType(p0,p1,p2,contourValue);
			if ((intersection==1&&p0>contourValue)||(intersection==4&&p0<contourValue))
			{
				x1=x01;
				y1=y01;
				x2=x02;
				y2=y02;
			}
			else if ((intersection==1&&p1>contourValue)||(intersection==4&&p1<contourValue))
			{
				x1=x01;
				y1=y01;
				x2=x12;
				y2=y12;
			}
			else if (intersection==1||intersection==4)
			{
				x1=x02;
				y1=y02;
				x2=x12;
				y2=y12;								
			}
			g.moveTo(x1,y1);
			g.lineTo(x2,y2);
		}

				
		private function getTriangleIntersectionType(p1:Number,p2:Number,p3:Number,value:Number):uint
		{
			var nAbove:uint=0;
			var nBelow:uint=0;
			var nEqual:uint=0;
			if (p1<value) nBelow++;
			else if (p1>value) nAbove++;
			else nEqual++;
			if (p2<value) nBelow++;
			else if (p2>value) nAbove++;
			else nEqual++;
			if (p3<value) nBelow++;
			else if (p3>value) nAbove++;
			else nEqual++;
			if (nBelow==2&&nAbove==1)
			{
				return 1;
			}
			else if (nBelow==1&&nAbove==2)
			{
				return 4;
			}
			else if (nBelow==1&&nAbove==1&&nEqual==1)
			{
				return 3;
			}
			else if (nBelow==1&&nEqual==2)
			{
				return 2;
			}
			else if (nAbove==1&&nEqual==2)
			{
				return 5;
			}			
			return 0;
		}
	}

}
