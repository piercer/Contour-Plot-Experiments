package
{

	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	[SWF(height="600",width="600")]
	public class ContourPlot extends Sprite
	{

		private static const WIDTH:Number = 600;
		private static const HEIGHT:Number = 600;
		private static const NPOINTS:Number = 50;

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
			plotContours(20);
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
			
			
			var x1:Number;
			var x2:Number;
			var y1:Number;
			var y2:Number;
			g.lineStyle(1,0x000000);

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

					for (k=0;k<nContours;k++)
					{
						var contourValue:Number = contourValues[k];

						var dp0:Number = contourValue-p0;
						var dp1:Number = contourValue-p1;
						var dp2:Number = contourValue-p2;
						var dp4:Number = 0.5*(contourValue-p4);
						
						var d04:Number = dp4/(p0-p4);
						var d14:Number = dp4/(p1-p4);
						var d24:Number = dp4/(p2-p4);
						var d34:Number = dp4/(p3-p4);
						
						var d20:Number = dp0/(p2-p0);
						var d10:Number = dp0/(p1-p0);
						var d31:Number = dp1/(p3-p1);
						var d32:Number = dp2/(p3-p2);
												
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
						intersection = getTriangleIntersectionType(p0,p4,p2,contourValue);
						if ((intersection==1&&p0>contourValue)||(intersection==4&&p0<contourValue))
						{
							x1=x20;
							y1=y20;
							x2=x04;
							y2=y04;
						}
						else if ((intersection==1&&p4>contourValue)||(intersection==4&&p4<contourValue))
						{
							x1=x04;
							y1=y04;
							x2=x24;
							y2=y24;
						}
						else if (intersection==1||intersection==4)
						{
							x1=x20;
							y1=y20;
							x2=x24;
							y2=y24;								
						}
						g.moveTo(x1,y1);
						g.lineTo(x2,y2);
						//
						//triangle 2
						//
						intersection = getTriangleIntersectionType(p0,p4,p1,contourValue);
						if ((intersection==1&&p0>contourValue)||(intersection==4&&p0<contourValue))
						{
							x1=x10;
							y1=y10;
							x2=x04;
							y2=y04;
						}
						else if ((intersection==1&&p4>contourValue)||(intersection==4&&p4<contourValue))
						{
							x1=x04;
							y1=y04;
							x2=x14;
							y2=y14;
						}
						else if (intersection==1||intersection==4)
						{
							x1=x10;
							y1=y10;
							x2=x14;
							y2=y14;								
						}
						g.moveTo(x1,y1);
						g.lineTo(x2,y2);
						//
						//triangle 3
						//
						intersection = getTriangleIntersectionType(p1,p4,p3,contourValue);
						if ((intersection==1&&p1>contourValue)||(intersection==4&&p1<contourValue))
						{
							x1=x14;
							y1=y14;
							x2=x31;
							y2=y31;
						}
						else if ((intersection==1&&p4>contourValue)||(intersection==4&&p4<contourValue))
						{
							x1=x14;
							y1=y14;
							x2=x34;
							y2=y34;
						}
						else if (intersection==1||intersection==4)
						{
							x1=x34;
							y1=y34;
							x2=x31;
							y2=y31;								
						}
						g.moveTo(x1,y1);
						g.lineTo(x2,y2);
						//
						//triangle 4
						//
						intersection = getTriangleIntersectionType(p3,p4,p2,contourValue);
						if ((intersection==1&&p2>contourValue)||(intersection==4&&p2<contourValue))
						{
							x1=x24;
							y1=y24;
							x2=x32;
							y2=y32;
						}
						else if ((intersection==1&&p4>contourValue)||(intersection==4&&p4<contourValue))
						{
							x1=x24;
							y1=y24;
							x2=x34;
							y2=y34;
						}
						else if (intersection==1||intersection==4)
						{
							x1=x34;
							y1=y34;
							x2=x32;
							y2=y32;								
						}
						g.moveTo(x1,y1);
						g.lineTo(x2,y2);
					}
				}
			}
			
		}
				
		private function getTriangleIntersectionType(p1:Number,p2:Number,p3:Number,value:Number):uint
		{
			var type:uint=0;
			var nAbove:uint=0;
			var nBelow:uint=0;
			var nEqual:uint=0;
			if (p1<value) nBelow++;
			if (p2<value) nBelow++;
			if (p3<value) nBelow++;
			if (p1>value) nAbove++;
			if (p2>value) nAbove++;
			if (p3>value) nAbove++;
			if (p1==value) nEqual++;
			if (p2==value) nEqual++;
			if (p3==value) nEqual++;
			if (nBelow==2&&nAbove==1)
			{
				type=1;
			}
			else if (nBelow==1&&nEqual==2)
			{
				type=2;
			}
			else if (nBelow==1&&nAbove==1&&nEqual==1)
			{
				type=3;
			}
			else if (nBelow==1&&nAbove==2)
			{
				type=4;
			}
			else if (nAbove==1&&nEqual==2)
			{
				type=5;
			}			
			return type;
		}
	}

}
