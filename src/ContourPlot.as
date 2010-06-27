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
		private static const NPOINTS:Number = 10;

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
			for (i=0;i<NPOINTS-1;i++)
			{

				for (j=0;j<NPOINTS-1;j++)
				{
					var p0:Number = _data[i][j];
					var p1:Number = _data[i+1][j];
					var p2:Number = _data[i][j+1];
					var p3:Number = _data[i+1][j+1];
					var p4:Number = (p0+p1+p2+p3)/4;

					for (k=0;k<nContours;k++)
					{
						var contourValue:Number = contourValues[k];
						var intersection:uint;
						g.lineStyle(1,0x000000);
						//
						//triangle 1
						//
						intersection = getTriangleIntersectionType(p0,p4,p2,contourValue);
						var d40:Number = (contourValue-p0)/(p4-p0);
						var d20:Number = (contourValue-p0)/(p2-p0);
						var d42:Number = (contourValue-p2)/(p4-p2);
						var d24:Number = (contourValue-p4)/(p2-p4);
						var d10:Number = (contourValue-p0)/(p1-p0);
						var d01:Number = (contourValue-p1)/(p0-p1);
						var d41:Number = (contourValue-p1)/(p4-p1);
						var d14:Number = (contourValue-p4)/(p1-p4);
						var d31:Number = (contourValue-p1)/(p3-p1);
						var d34:Number = (contourValue-p4)/(p3-p4);
						var d32:Number = (contourValue-p2)/(p3-p2);
						if (intersection==1)
						{
							if (p0>contourValue)
							{
								x1=i*dx;
								y1=(j+d20)*dy;
								x2=(i+0.5*d40)*dx;
								y2=(j+0.5*d40)*dy;
							}
							else if (p4>contourValue)
							{
								x1=(i+0.5*d40)*dx;
								y1=(j+0.5*d40)*dy;
								x2=(i+0.5-0.5*d24)*dx;
								y2=(j+0.5+0.5*d24)*dy;
							}
							else
							{
								x1=i*dx;
								y1=(j+d20)*dy;
								x2=(i+0.5*d42)*dx;
								y2=(j+1-0.5*d42)*dy;								
							}
							g.moveTo(x1,y1);
							g.lineTo(x2,y2);
						}
						else if (intersection==4)
						{
							if (p0<contourValue)
							{
								x1=i*dx;
								y1=(j+d20)*dy;
								x2=(i+0.5*d40)*dx;
								y2=(j+0.5*d40)*dy;
							}
							else if (p4<contourValue)
							{
								x1=(i+0.5*d40)*dx;
								y1=(j+0.5*d40)*dy;
								x2=(i+0.5-0.5*d24)*dx;
								y2=(j+0.5+0.5*d24)*dy;
							}
							else
							{
								x1=i*dx;
								y1=(j+d20)*dy;
								x2=(i+0.5*d42)*dx;
								y2=(j+1-0.5*d42)*dy;								
							}
							g.moveTo(x1,y1);
							g.lineTo(x2,y2);
						}
						//
						//triangle 2
						//
						intersection = getTriangleIntersectionType(p0,p4,p1,contourValue);
						if (intersection==1)
						{
							if (p0>contourValue)
							{
								x1=(i+d10)*dx;
								y1=j*dy;
								x2=(i+0.5*d40)*dx;
								y2=(j+0.5*d40)*dy;
							}
							else if (p4>contourValue)
							{
								x1=(i+0.5*d40)*dx;
								y1=(j+0.5*d40)*dy;
								x2=(i+0.5+0.5*d14)*dx;
								y2=(j+0.5-0.5*d14)*dy;
							}
							else
							{
								x1=(i+1-d01)*dx;
								y1=j*dy;
								x2=(i+0.5+0.5*d14)*dx;
								y2=(j+0.5-0.5*d14)*dy;								
							}
							g.moveTo(x1,y1);
							g.lineTo(x2,y2);
						}
						else if (intersection==4)
						{
							if (p0<contourValue)
							{
								x1=(i+d10)*dx;
								y1=j*dy;
								x2=(i+0.5*d40)*dx;
								y2=(j+0.5*d40)*dy;
							}
							else if (p4<contourValue)
							{
								x1=(i+0.5*d40)*dx;
								y1=(j+0.5*d40)*dy;
								x2=(i+0.5+0.5*d14)*dx;
								y2=(j+0.5-0.5*d14)*dy;
							}
							else
							{
								x1=(i+1-d01)*dx;
								y1=j*dy;
								x2=(i+0.5+0.5*d14)*dx;
								y2=(j+0.5-0.5*d14)*dy;								
							}
							g.moveTo(x1,y1);
							g.lineTo(x2,y2);							
						}
						//
						//triangle 3
						//
						intersection = getTriangleIntersectionType(p1,p4,p3,contourValue);
						if (intersection==1)
						{
							if (p1>contourValue)
							{
								x1=(i+0.5+0.5*d14)*dx;
								y1=(j+0.5-0.5*d14)*dy;
								x2=(i+1)*dx;
								y2=(j+d31)*dy;
							}
							else if (p4>contourValue)
							{
								x1=(i+0.5+0.5*d14)*dx;
								y1=(j+0.5-0.5*d14)*dy;
								x2=(i+0.5+0.5*d34)*dx;
								y2=(j+0.5+0.5*d34)*dy;
							}
							else
							{
								x1=(i+0.5+0.5*d34)*dx;
								y1=(j+0.5+0.5*d34)*dy;
								x2=(i+1)*dx;
								y2=(j+d31)*dy;								
							}
							g.moveTo(x1,y1);
							g.lineTo(x2,y2);
						}
						else if (intersection==4)
						{
							if (p1<contourValue)
							{
								x1=(i+0.5+0.5*d14)*dx;
								y1=(j+0.5-0.5*d14)*dy;
								x2=(i+1)*dx;
								y2=(j+d31)*dy;
							}
							else if (p4<contourValue)
							{
								x1=(i+0.5+0.5*d14)*dx;
								y1=(j+0.5-0.5*d14)*dy;
								x2=(i+0.5+0.5*d34)*dx;
								y2=(j+0.5+0.5*d34)*dy;
							}
							else
							{
								x1=(i+0.5+0.5*d34)*dx;
								y1=(j+0.5+0.5*d34)*dy;
								x2=(i+1)*dx;
								y2=(j+d31)*dy;								
							}
							g.moveTo(x1,y1);
							g.lineTo(x2,y2);
						}
						//
						//triangle 4
						//
						intersection = getTriangleIntersectionType(p3,p4,p2,contourValue);
						if (intersection==1)
						{
							if (p2>contourValue)
							{
								x1=(i+0.5*d42)*dx;
								y1=(j+1-0.5*d42)*dy;
								x2=(i+d32)*dx;
								y2=(j+1)*dy;
							}
							else if (p4>contourValue)
							{
								x1=(i+0.5*d42)*dx;
								y1=(j+1-0.5*d42)*dy;
								x2=(i+0.5+0.5*d34)*dx;
								y2=(j+0.5+0.5*d34)*dy;
							}
							else
							{
								x1=(i+0.5+0.5*d34)*dx;
								y1=(j+0.5+0.5*d34)*dy;
								x2=(i+d32)*dx;
								y2=(j+1)*dy;								
							}
							g.moveTo(x1,y1);
							g.lineTo(x2,y2);
						}
						else if (intersection==4)
						{
							x1=0;
							y1=0;
							x2=0;
							y2=0;
							if (p2<contourValue)
							{
								x1=(i+0.5*d42)*dx;
								y1=(j+1-0.5*d42)*dy;
								x2=(i+d32)*dx;
								y2=(j+1)*dy;
							}
							else if (p4<contourValue)
							{
								x1=(i+0.5*d42)*dx;
								y1=(j+1-0.5*d42)*dy;
								x2=(i+0.5+0.5*d34)*dx;
								y2=(j+0.5+0.5*d34)*dy;
							}
							else
							{
								x1=(i+0.5+0.5*d34)*dx;
								y1=(j+0.5+0.5*d34)*dy;
								x2=(i+d32)*dx;
								y2=(j+1)*dy;								
							}
							g.moveTo(x1,y1);
							g.lineTo(x2,y2);
						}
						

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
