// Voronoi calculation example code
//
// Author   : Chris H. Rycroft (LBL / UC Berkeley)
// Email    : chr@alum.mit.edu
// Date     : May 18th 2011

#include "voro++.hh"

// Constants determining the configuration of the tori
const double dis=1.25,mjrad=2.5,mirad=0.95,trad=mjrad+mirad;

// Set the number of particles that are going to be randomly introduced
const int particles=100000;

// This function returns a random double between 0 and 1
double rnd() {return double(rand())/RAND_MAX;}

int main() {
	int i;
	double x,y,z,r;
	voronoicell c;

	// Create a container as a non-periodic 10 by 10 by 10 box
	container con(-5,5,-5,5,-5,5,26,26,26,false,false,false,8);
	voropp_order vo;
	
	// Randomly add particles into the container
	for(i=0;i<particles;i++) {
		x=10*rnd()-5;
		y=10*rnd()-5;
		z=10*rnd()-5;

		// If the particle lies within the first torus, store it in the
		// ordering class when adding to the container
		r=sqrt((x-dis)*(x-dis)+y*y);
		if((r-mjrad)*(r-mjrad)+z*z<mirad) con.put(vo,i,x,y,z);
		else con.put(i,x,y,z);
	}

	// Compute Voronoi cells for the first torus. Here, the points
	// previously stored in the ordering class are looped over.
	FILE *f1(voropp_safe_fopen("loops1_m.pov","w"));
	FILE *f2(voropp_safe_fopen("loops1_v.pov","w"));
	v_loop_order vlo(con,vo);
	if(vlo.start()) do if(con.compute_cell(c,vlo)) {
		vlo.pos(x,y,z);
		
		// Save a POV-Ray mesh to one file and a cylinder/sphere
		// representation to the other file
		c.draw_pov_mesh(x,y,z,f1);
		c.draw_pov(x,y,z,f2);
	} while (vlo.inc());
	fclose(f1);
	fclose(f2);

	// Compute Voronoi cells for the second torus. Here, the subset loop is
	// used to search over the blocks overlapping the torus, and then each
	// particle is individually tested.
	f1=voropp_safe_fopen("loops2_m.pov","w");
	f2=voropp_safe_fopen("loops2_v.pov","w");
	v_loop_subset vls(con);
	vls.setup_box(-dis-trad,-dis+trad,-mirad,mirad,-trad,trad,false);
	if(vls.start()) do {
		vls.pos(x,y,z);

		// Test whether this point is within the torus, and if so,
		// compute and save the Voronoi cell
		r=sqrt((x+dis)*(x+dis)+z*z);
		if((r-mjrad)*(r-mjrad)+y*y<mirad&&con.compute_cell(c,vls)) {
			c.draw_pov_mesh(x,y,z,f1);
			c.draw_pov(x,y,z,f2);
		}
	} while (vls.inc());
	fclose(f1);
	fclose(f2);
}
