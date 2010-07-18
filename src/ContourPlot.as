package
{

	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	[SWF(height="600",width="600")]
	public class ContourPlot extends Sprite
	{

		private static const WIDTH:Number = 600;
		private static const HEIGHT:Number = 600;
		private static const NPOINTS:Number = 50;

		private var _data:Array;
		private var _zmax:Number;
		private var _zmin:Number;
		private var _contourValue:Number;
		private var _checkedEdges:Array;
		private var _dx:Number;
		private var _dy:Number;
		
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
			plotContours(30);
		}
		
		private function plotContours(nContours:uint):void
		{
			var i:uint;
			var j:uint;
			var k:uint;
			var x:Number;
			var y:Number;
			var gradient:Number;
			
			_dx = WIDTH/(NPOINTS-1);
			_dy = HEIGHT/(NPOINTS-1);
			
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
				x=i*_dx;
				g.moveTo(x,0);
				g.lineTo(x,HEIGHT);
			}
			for (i=0;i<NPOINTS;i++)
			{
				y=i*_dy;
				g.moveTo(0,y);
				g.lineTo(WIDTH,y);
			}
			for (i=0;i<NPOINTS;i++)
			{
				x=i*_dx;
				for (j=0;j<NPOINTS;j++)
				{
					y=j*_dy;
					g.moveTo(x,y);
					g.lineTo(x+_dx,y+_dy);
					g.moveTo(x+_dx,y);
					g.lineTo(x,y+_dy);
				}
			}
			
			g=graphics;
			g.lineStyle(1,0x000000);
			
			var np:uint = NPOINTS-1;

			var startTime:int = getTimer();
			
			_checkedEdges = [];
			for (i=0;i<np;i++)
			{
				_checkedEdges[i]=[];
				for (j=0;j<np;j++)
				{
					_checkedEdges[i][j]=[];
					for (k=0;k<nContours;k++)
					{
						_checkedEdges[i][j][k]=[];
					}
				}
			}
			
			for (i=0;i<np;i++)
			{				
				for (k=0;k<nContours;k++)
				{
					_contourValue = contourValues[k];
					graphics.lineStyle(1,Math.random()*0xFFFFFF);
					checkEdge2(i,0,k,true);
					checkEdge4(i,np-1,k,true);
				}				
			}
			for (j=0;j<np;j++)
			{				
				for (k=0;k<nContours;k++)
				{
					_contourValue = contourValues[k];
					graphics.lineStyle(1,Math.random()*0xFFFFFF);
					checkEdge1(0,j,k,true);
					checkEdge3(0,np-1,k,true);
				}				
			}

		}
		
		private function checkEdge1(i:uint,j:uint,k:uint,start:Boolean=false):String
		{
			if (_checkedEdges[i][j][k][1])
			{
				return "";
			}
			_checkedEdges[i][j][k][1]=true;
			var p0:Number = _data[i][j];
			var p2:Number = _data[i][j+1];
			if ((p0<_contourValue&&p2>_contourValue)||(p0>_contourValue&&p2<_contourValue))
			{
				var dp0:Number = _contourValue-p0;
				var dp20:Number = p2-p0;				
				var d20:Number = dp0/dp20;				
				var x20:Number = i*_dx;
				var y20:Number = (j+d20)*_dy;
				if (start)
				{
					graphics.moveTo(x20,y20);
				}
				else
				{
					graphics.lineTo(x20,y20);					
				}
				checkEdge5(i,j,k,1);
				checkEdge7(i,j,k,1);
			}
			return "";
		}
		
		private function checkEdge2(i:uint,j:uint,k:uint,start:Boolean=false):String
		{
			if (_checkedEdges[i][j][k][2])
			{
				return "";
			}
			_checkedEdges[i][j][k][2]=true;
			var p0:Number = _data[i][j];
			var p1:Number = _data[i+1][j];
			if ((p0<_contourValue&&p1>_contourValue)||(p0>_contourValue&&p1<_contourValue))
			{
				var dp0:Number = _contourValue-p0;
				var dp10:Number = p1-p0;
				var d10:Number = dp0/dp10;
				var x10:Number = (i+d10)*_dx;
				var y10:Number = j*_dy;

				if (start)
				{
					graphics.moveTo(x10,y10);					
				}
				else
				{
					graphics.lineTo(x10,y10);					
				}
				checkEdge5(i,j,k,2);
				checkEdge6(i,j,k,2);
			}
			return "";
		}

		private function checkEdge3(i:uint,j:uint,k:uint,start:Boolean=false):String
		{
			if (_checkedEdges[i][j][k][3])
			{
				return "";
			}
			_checkedEdges[i][j][k][3]=true;
			var p1:Number = _data[i+1][j];
			var p3:Number = _data[i+1][j+1];
			if ((p1<_contourValue&&p3>_contourValue)||(p1>_contourValue&&p3<_contourValue))
			{
				var dp1:Number = _contourValue-p1;
				var dp31:Number = p3-p1;
				var d31:Number = dp1/dp31;
				var x31:Number = (i+1)*_dx;
				var y31:Number = (j+d31)*_dy;
				if (start)
				{
					graphics.moveTo(x31,y31);
				}
				else
				{
					graphics.lineTo(x31,y31);					
				}
				checkEdge6(i,j,k,3);
				checkEdge8(i,j,k,3);
			}
			return "";
		}
		
		private function checkEdge4(i:uint,j:uint,k:uint,start:Boolean=false):String
		{
			if (_checkedEdges[i][j][k][4])
			{
				return "";
			}
			_checkedEdges[i][j][k][4]=true;
			var p2:Number = _data[i][j+1];
			var p3:Number = _data[i+1][j+1];
			if ((p2<_contourValue&&p3>_contourValue)||(p2>_contourValue&&p3<_contourValue))
			{
				var dp2:Number = _contourValue-p2;
				var dp32:Number = p3-p2;
				var d32:Number = dp2/dp32;			
				var x32:Number = (i+d32)*_dx;
				var y32:Number = (j+1)*_dy;
				if (start)
				{
					graphics.moveTo(x32,y32);					
				}
				else
				{
					graphics.lineTo(x32,y32);
				}
				graphics.lineTo(x32,y32);
				checkEdge7(i,j,k,4);
				checkEdge8(i,j,k,4);
			}
			return "";
		}
		
		private function checkEdge5(i:uint,j:uint,k:uint,outsideEdge:uint):String
		{
			if (_checkedEdges[i][j][k][5])
			{
				return "";
			}
			_checkedEdges[i][j][k][5]=true;
			var p0:Number = _data[i][j];
			var p1:Number = _data[i+1][j];
			var p2:Number = _data[i][j+1];
			var p3:Number = _data[i+1][j+1];
			var p4:Number = (p0+p1+p2+p3)/4;
			if ((p0<_contourValue&&p4>_contourValue)||(p0>_contourValue&&p4<_contourValue))
			{
				var dp4:Number = 0.5*(_contourValue-p4);
				var dp04:Number = p0-p4;
				var d04:Number = dp4/dp04;
				var x04:Number = (i+0.5-d04)*_dx;
				var y04:Number = (j+0.5-d04)*_dy;

				graphics.lineTo(x04,y04);
				if (outsideEdge==1||outsideEdge==7)
				{
					if (j>0)
					{
						checkEdge4(i,j-1,k);
					}
					checkEdge6(i,j,k,5);
				}
				else
				{
					if (i>0)
					{
						checkEdge3(i-1,j,k);
					}
					checkEdge7(i,j,k,5);
				}
			}
			return "";
		}
		
		private function checkEdge6(i:uint,j:uint,k:uint,outsideEdge:uint):String
		{
			if (_checkedEdges[i][j][k][6])
			{
				return "";
			}
			_checkedEdges[i][j][k][6]=true;
			var p0:Number = _data[i][j];
			var p1:Number = _data[i+1][j];
			var p2:Number = _data[i][j+1];
			var p3:Number = _data[i+1][j+1];
			var p4:Number = (p0+p1+p2+p3)/4;
			if ((p1<_contourValue&&p4>_contourValue)||(p1>_contourValue&&p4<_contourValue))
			{
				var dp14:Number = p1-p4;
				var dp4:Number = 0.5*(_contourValue-p4);
				var d14:Number = dp4/dp14;
				var x14:Number = (i+0.5+d14)*_dx;
				var y14:Number = (j+0.5-d14)*_dy;

				graphics.lineTo(x14,y14);
				if (outsideEdge==2||outsideEdge==5)
				{
					if (i<NPOINTS-2)
					{
						checkEdge1(i+1,j,k);
					}
					checkEdge8(i,j,k,6);
				}
				else
				{
					checkEdge5(i,j,k,6);
					if (j>0)
					{
						checkEdge4(i,j-1,k);
					}
				}
			}
			return "";
		}
		
		private function checkEdge7(i:uint,j:uint,k:uint,outsideEdge:uint):String
		{
			if (_checkedEdges[i][j][k][7])
			{
				return "";
			}
			_checkedEdges[i][j][k][7]=true;
			var p0:Number = _data[i][j];
			var p1:Number = _data[i+1][j];
			var p2:Number = _data[i][j+1];
			var p3:Number = _data[i+1][j+1];
			var p4:Number = (p0+p1+p2+p3)/4;
			if ((p2<_contourValue&&p4>_contourValue)||(p2>_contourValue&&p4<_contourValue))
			{
				var dp4:Number = 0.5*(_contourValue-p4);
				var dp24:Number = p2-p4;
				var d24:Number = dp4/dp24;
				var x24:Number = (i+0.5-d24)*_dx;
				var y24:Number = (j+0.5+d24)*_dy;

				graphics.lineTo(x24,y24);
				if (outsideEdge==4||outsideEdge==8)
				{
					checkEdge5(i,j,k,7);
					if (j>0)
					{
						checkEdge3(i-1,j,k);						
					}
				}
				else
				{
					if (j<NPOINTS-2)
					{
						checkEdge2(i,j+1,k);
					}
					checkEdge8(i,j,k,7);
				}
			}			
			return "";
		}

		private function checkEdge8(i:uint,j:uint,k:uint,outsideEdge:uint):String
		{
			if (_checkedEdges[i][j][k][8])
			{
				return "";
			}
			_checkedEdges[i][j][k][8]=true;
			var p0:Number = _data[i][j];
			var p1:Number = _data[i+1][j];
			var p2:Number = _data[i][j+1];
			var p3:Number = _data[i+1][j+1];
			var p4:Number = (p0+p1+p2+p3)/4;			
			if ((p3<_contourValue&&p4>_contourValue)||(p3>_contourValue&&p4<_contourValue))
			{
				var dp4:Number = 0.5*(_contourValue-p4);
				var dp34:Number = p3-p4;
				var d34:Number = dp4/dp34;
				var x34:Number = (i+0.5+d34)*_dx;
				var y34:Number = (j+0.5+d34)*_dy;

				graphics.lineTo(x34,y34);
				if (outsideEdge==4||outsideEdge==7)
				{
					if (i<NPOINTS-2)
					{
						checkEdge1(i+1,j,k);
					}
					checkEdge6(i,j,k,8);
				}
				else
				{
					if (j<NPOINTS-2)
					{
						checkEdge2(i,j+1,k);
					}
					checkEdge7(i,j,k,8);
				}
			}			
			return "";
		}

	}

}
