#include <vtkVersion.h>
#include <vtkSmartPointer.h>
#include <vtkSphereSource.h>
#include <vtkPolyDataMapper.h>
#include <vtkActor.h>
#include <vtkRenderer.h>
#include <vtkRenderWindow.h>
#include <vtkRenderWindowInteractor.h>

int main(int argc, char* argv[])
{
    // Print version — confirms headers and linkage are consistent
    std::cout << "VTK version: " << vtkVersion::GetVTKVersionFull() << std::endl;

    // Exercise the pipeline: source → mapper → actor → renderer → window
    auto sphere = vtkSmartPointer<vtkSphereSource>::New();
    sphere->SetRadius(1.0);
    sphere->SetThetaResolution(16);
    sphere->SetPhiResolution(16);
    sphere->Update();

    auto mapper = vtkSmartPointer<vtkPolyDataMapper>::New();
    mapper->SetInputConnection(sphere->GetOutputPort());

    auto actor = vtkSmartPointer<vtkActor>::New();
    actor->SetMapper(mapper);

    auto renderer = vtkSmartPointer<vtkRenderer>::New();
    renderer->AddActor(actor);
    renderer->SetBackground(0.1, 0.2, 0.4);

    auto renderWindow = vtkSmartPointer<vtkRenderWindow>::New();
    renderWindow->AddRenderer(renderer);
    renderWindow->SetSize(400, 400);
    renderWindow->SetOffScreenRendering(1);  // no display required — CI friendly
    renderWindow->Render();

    std::cout << "Render completed successfully." << std::endl;

    return 0;
}